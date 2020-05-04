package cobbles.native;

#if (cpp && !doc_gen)

// `this_dir` is the build output directory (out/cpp/)
@:buildXml("
    <include name='${haxelib:cobbles}/native/hxcpp_config.xml' if='haxelib:cobbles'/>
    <include name='${this_dir}/../../native/hxcpp_config.xml' unless='haxelib:cobbles'/>
")
@:keep
class HxcppConfig {

}


#end
