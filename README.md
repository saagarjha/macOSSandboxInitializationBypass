# macOS Sandbox Initialization Bypass

These are the sample applications I submitted to Apple to demonstrate issues in the macOS sandbox initialization process, which allowed a malicious application to be submitted to the Mac App Store that could nonetheless perform operations that would normally be blocked by the platform sandbox. Apple has made changes in the Mac App Store in response to the report I submitted to them.

Two sample projects are provided, SandboxEscape and StaticSandboxEscape, which demonstrate initialization bypasses using dyld interposing and static linking, respectively. An additional file, [sandboxescape.c](https://github.com/saagarjha/macOSSandboxInitializationBypass/blob/master/sandboxescape.c), is provided to demonstrate the third bypass technique, which must be compiled with an old SDK toolchain (such as Xcode 5.1.1) so that the linker honors the `-no_new_main` flag. The resulting binary should have its `LC_LOAD_DYLIB` load command for libSystem removed and replace the executable from the static linking example.
