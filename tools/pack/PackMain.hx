package;

import haxe.Template;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

class PackMain {
	private static inline var indexSrc:String = "assets/index.html";
	private static inline var scriptSrc:String = "build/main.js";
	private static inline var scriptMin:String = "build/main-min.js";
	private static inline var scriptRoll:String = "build/main-roll.js";
	private static inline var zzfxSrc:String = "assets/ZzFXMicro.min.js";

	private static inline var finalDir:String = "build/final/";
	private static inline var finalUncompressedDir:String = finalDir + "uncompressed/";
	private static inline var finalMinifiedDir:String = finalDir + "min/";
	private static inline var packageFile:String = finalDir + "13-curses.zip";

	private static var lastSize:Int = -1;

	#if ROADROLLER
	private static inline var ROAD_ROLLER = true;
	#else
	private static inline var ROAD_ROLLER = false;
	#end

	public static function main() {
		if (FileSystem.exists(packageFile)) {
			lastSize = FileSystem.stat(packageFile).size;
		}

		clean();
		minify();
		build(scriptSrc, "index.html");
		build(scriptMin, "index-m.html");
		if (ROAD_ROLLER) {
			build(scriptRoll, "index-r.html");
		}
		minifyHtml(ROAD_ROLLER ? "index-r.html" : "index-m.html");
		pack();
	}

	public static function clean() {
		FileSystem.createDirectory(finalUncompressedDir);
		FileSystem.createDirectory(finalMinifiedDir);

		function cleanDir(dir) {
			for (f in FileSystem.readDirectory(dir)) {
				if (!FileSystem.isDirectory(dir + f)) {
					FileSystem.deleteFile(dir + f);
				}
			}
		}

		cleanDir(finalMinifiedDir);
		cleanDir(finalUncompressedDir);
		cleanDir(finalDir);
	}

	public static function minify() {
		Sys.command("uglifyjs", ["-o", scriptMin, scriptSrc]);
		if (ROAD_ROLLER) {
			Sys.command("npx", ["roadroller", scriptMin, "-o", scriptRoll]);
		}
	}

	public static function build(scriptFile, outputFile) {
		var pageTemplate:String = File.getContent(indexSrc);
		var script:String = File.getContent(scriptFile);
		var zzfx:String = File.getContent(zzfxSrc);

		var tpl:Template = new Template(pageTemplate);
		var out:String = tpl.execute({src: script, zzfx: zzfx});

		File.saveContent(finalUncompressedDir + outputFile, out);
	}

	public static function minifyHtml(buildFile) {
		Sys.command("html-minifier", [
			"--collaspse-boolean-attributes",
			"--collapse-inline-tag-whitespace",
			"--collapse-whitespace",
			"--decode-entities",
			"--html5",
			"--minify-css",
			"--minify-js",
			"--remove-attribute-quotes",
			"--remove-comments",
			"--remove-empty-attributes",
			"--remove-optional-tags",
			"--remove-redundant-attributes",
			"--use-short-doctype",
			"-o",
			finalMinifiedDir + "index.html",
			finalUncompressedDir + buildFile
		]);
	}

	public static function pack() {
		Sys.command("7z", [
			"a",
			packageFile,
			"./" + finalMinifiedDir + "*",
			"-mx9",
			"-mtc=off",
			"-mfb=258",
			"-mpass=15"
		]);

		var bytes:Int = FileSystem.stat(packageFile).size;
		trace(Std.string(bytes / 1024) + " / 13kb bytes used!");
		trace(Std.string((bytes / 1024) / 0.13) + "%");

		trace(Std.string(bytes - lastSize) + " bytes from last build");
	}
}
