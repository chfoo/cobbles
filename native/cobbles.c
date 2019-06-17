#include "cobbles.h"
#include <assert.h>
#include <errno.h>
#include <hb.h>
#include <iconv.h>
#include <stdbool.h>
#include <stdlib.h>

Cobbles * cobbles_init(CobblesEncoding encoding) {
    Cobbles * cobbles = calloc(1, sizeof(Cobbles));

    if (cobbles == NULL) {
        return NULL;
    }

    int error = FT_Init_FreeType(&(cobbles->ft_library));

    if (error != 0) {
        _cobbles_debug_print("FT_Init_FreeType error %d\n", error);
    }

    cobbles->error_code = error;
    cobbles->encoding = encoding;
    cobbles->hb_unicode_funcs = hb_unicode_funcs_get_default();

    return cobbles;
}

void cobbles_destroy(Cobbles * cobbles) {
    assert(cobbles != NULL);
    FT_Done_FreeType(cobbles->ft_library);

    if (cobbles->encodingStringBuffer != NULL) {
        free(cobbles->encodingStringBuffer);
    }

    free(cobbles);
}

int cobbles_get_error(Cobbles * cobbles) {
    assert(cobbles != NULL);
    return cobbles->error_code;
}

int cobbles_guess_string_script(Cobbles * cobbles, const char * text) {
    assert(cobbles != NULL);
    assert(text != NULL);

    hb_script_t script = HB_SCRIPT_UNKNOWN;
    hb_direction_t direction = HB_DIRECTION_LTR;
    char script_str[4];
    const uint32_t * code_points = _cobbles_get_code_points(cobbles, text);

    assert(code_points != NULL);

    for (size_t index = 0; code_points[index] != 0; index++) {
        script = hb_unicode_script(
            cobbles->hb_unicode_funcs, code_points[index]);

        if (script != HB_SCRIPT_COMMON &&
        script != HB_SCRIPT_INHERITED &&
        script != HB_SCRIPT_UNKNOWN) {
            break;
        }
    }

    direction = hb_script_get_horizontal_direction(script);
    hb_tag_to_string(hb_script_to_iso15924_tag(script), script_str);

    return (script_str[0] << 24) |
        (script_str[1] << 16) |
        (script_str[2] << 8) |
        script_str[3] |
        (direction == HB_DIRECTION_RTL ? 1 << 31 : 0);
}

void _cobbles_debug_print(char * message, ...) {
    #ifndef NDEBUG
    va_list argptr;
    va_start(argptr, message);
    vfprintf(stderr, message, argptr);
    va_end(argptr);
    #endif
}

int _cobbles_bytes_read_int(uint8_t * bytes, int index) {
    return bytes[index] |
        (bytes[index + 1] << 8) |
        (bytes[index + 2] << 16) |
        (bytes[index + 3] << 24);
}

void _cobbles_bytes_write_int(uint8_t * bytes, int index, int value) {
    bytes[index] = value & 0xff;
    bytes[index + 1] = (value >> 8) & 0xff;
    bytes[index + 2] = (value >> 16) & 0xff;
    bytes[index + 3] = (value >> 24) & 0xff;
}

size_t _cobbles_string_length(Cobbles * cobbles, const char * input) {
    assert(cobbles != NULL);
    assert(input != NULL);

    if (cobbles->encoding == COBBLES_UTF8) {
        return strlen(input);
    }

    size_t length = 0;

    while (true) {
        int value;

        if (cobbles->encoding == COBBLES_UTF32) {
            value = input[length] |
                input[length + 1] |
                input[length + 2] |
                input[length + 3];
            length += 4;
        } else {
            value = input[length] | input[length + 1];
            length += 2;
        }

        if (value == 0) {
            break;
        }
    }

    return length;
}

const char* _cobbles_encode_string(Cobbles * cobbles,
        const char * inputEncoding,
        const char * outputEncoding, const char * input) {
    assert(cobbles != NULL);
    assert(inputEncoding != NULL);
    assert(outputEncoding != NULL);
    assert(input != NULL);

    iconv_t converter = iconv_open(outputEncoding, inputEncoding);

    if (converter == (iconv_t)(-1)) {
        _cobbles_debug_print("iconv_open error %d\n", errno);
        return NULL;
    }

    if (cobbles->encodingStringBuffer != NULL) {
        free(cobbles->encodingStringBuffer);
    }

    const size_t terminatorLength = 1;
    const size_t inputLength = _cobbles_string_length(cobbles, input);
    const size_t bufferSize = 128;
    char buffer[bufferSize];
    char * bufferCursor = (char *) &buffer;
    const char * inputCursor = input;
    size_t inputBytesLeft = inputLength;
    size_t prevInputBytesLeft = inputBytesLeft;
    size_t bufferBytesLeft = bufferSize;

    char * outputBuffer = malloc(bufferSize);
    size_t outputIndex = 0;
    size_t outputLength = bufferSize;

    if (outputBuffer == NULL) {
        _cobbles_debug_print("outputBuffer malloc error %d\n", errno);
        return NULL;
    }

    while (inputBytesLeft > 0) {
        bufferBytesLeft = bufferSize;
        bufferCursor = (char *) &buffer;
        bool full = false;

        size_t result = iconv(converter,
            (char **) &inputCursor, &inputBytesLeft,
            &bufferCursor, &bufferBytesLeft);

        if (result == (size_t)(-1)) {
            if (errno == 0) {
                // Well, I guess we have the wrong library linked...
                if (prevInputBytesLeft != inputBytesLeft) {
                    // Probably stalled, so assume EINVAL
                    inputBytesLeft = 0;
                }
            } else if (errno == E2BIG) {
                // continue on with converting segments of bytes
            } else if (errno == EILSEQ || errno == EINVAL) {
                _cobbles_debug_print("iconv error %d\n", errno);
                // FIXME: we should put a replacement character and skip the
                // invalid sequence
                inputBytesLeft = 0;
            } else {
                _cobbles_debug_print("iconv unknown error %d\n", errno);
                return NULL;
            }
        }

        size_t bytesWritten = bufferSize - bufferBytesLeft;
        if (outputIndex + bytesWritten + terminatorLength > outputLength) {
            outputLength *= 2;
            outputBuffer = realloc(outputBuffer, outputLength);

            if (outputBuffer == NULL) {
                _cobbles_debug_print("outputBuffer realloc error %d\n", errno);
                return NULL;
            }
        }

        memcpy(&(outputBuffer[outputIndex]), buffer, bytesWritten);
        outputIndex += bytesWritten;
        prevInputBytesLeft = inputBytesLeft;
    }

    outputBuffer[outputIndex + 1] = 0; // null terminator
    cobbles->encodingStringBuffer = outputBuffer;
    iconv_close(converter);

    #ifdef COBBLES_DEBUG
    printf("conv str: '%s'\n", outputBuffer);
    #endif
    return outputBuffer;
}

const char* _cobbles_get_utf8_string(Cobbles * cobbles, const char * input) {
    if (cobbles->encoding == COBBLES_UTF8) {
        #ifdef COBBLES_DEBUG
        printf("c str: '%s'\n", input);
        #endif
        return input;
    }

    return _cobbles_encode_string(cobbles,
        cobbles->encoding == COBBLES_UTF32 ? "UTF-32LE" : "UTF-16LE",
        "UTF-8",
        input);
}

const uint32_t* _cobbles_get_code_points(Cobbles * cobbles, const char * input) {
    const char * input_encoding;

    switch (cobbles->encoding) {
        case COBBLES_UTF16: input_encoding = "UTF-16LE"; break;
        case COBBLES_UTF32: input_encoding = "UTF-32LE"; break;
        default: input_encoding = "UTF-8"; break;
    }

    return (const uint32_t*) _cobbles_encode_string(cobbles,
        input_encoding,
        "UTF-32LE",
        input);
}


#ifdef COBBLES_HL
DEFINE_PRIM(_ABSTRACT(Cobbles), cobbles_init, _I32);
DEFINE_PRIM(_VOID, cobbles_destroy, _ABSTRACT(Cobbles));
DEFINE_PRIM(_I32, cobbles_get_error, _ABSTRACT(Cobbles));
DEFINE_PRIM(_I32, cobbles_guess_string_script, _ABSTRACT(Cobbles) _BYTES);
#endif
