#include "cobbles.h"
#include <malloc.h>

Cobbles * cobbles_init() {
    Cobbles * cobbles = calloc(1, sizeof(Cobbles));

    if (cobbles == NULL) {
        return NULL;
    }

    int error = FT_Init_FreeType(&(cobbles->ft_library));

    cobbles->error_code = error;
    return cobbles;
}

void cobbles_destroy(Cobbles * cobbles) {
    FT_Done_FreeType(cobbles->ft_library);
    free(cobbles);
}

int cobbles_get_error(Cobbles * cobbles) {
    return cobbles->error_code;
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

#ifdef LIBHL_EXPORTS
DEFINE_PRIM(_ABSTRACT(Cobbles), cobbles_init, _NO_ARG);
DEFINE_PRIM(_VOID, cobbles_destroy, _ABSTRACT(Cobbles));
DEFINE_PRIM(_I32, cobbles_get_error, _ABSTRACT(Cobbles));
#endif
