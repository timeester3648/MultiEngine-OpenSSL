include "../../premake/common_premake_defines.lua"

project "OpenSSL"
	kind "StaticLib"
	language "C++"
	cppdialect "C++latest"
	cdialect "C17"
	targetname "%{prj.name}"
	inlining "Auto"

	includedirs {
		"%{IncludeDir.zlib}",
		"%{IncludeDir.openssl}",

		".",
		"./crypto",
		"./crypto/",
		"./crypto/modes",
		"./crypto/include",
		"./crypto/ec/curve448",
		"./providers/common/include",
		"./crypto/ec/curve448/arch_32",
		"./providers/implementations/include"
	}

	files {
		"./ssl/**.h",
		"./ssl/**.c",
		"./crypto/**.h",
		"./crypto/**.c",

		"./engines/e_capi.c",
		"./engines/e_padlock.c",

		"./providers/*.h",
		"./providers/baseprov.c",
		"./providers/nullprov.c",
		"./providers/defltprov.c",
		"./providers/prov_running.c",
		"./providers/implementations/asymciphers/rsa_enc.c",

		"./**.h.in",
		"./**x86_64.pl",
		"./util/mkbuildinf.pl"
	}

	excludes {
		"./crypto/ec/ecp_nistz256_table.c",
		"./crypto/rsa/rsa_acvp_test_params.c",

		"./crypto/md2/**",
		"./crypto/rc5/**",
		"./crypto/evp/**md2**",

		"./**riscv**"
	}

	filter "toolset:msc"
		disablewarnings { "4311", "4996", "4267", "4244", "4305", "4013", "4133", "4334" }

	filter "system:windows"
		defines {
			"WIN32_LEAN_AND_MEAN",
			"OPENSSL_PIC",
			"L_ENDIAN",
			"OPENSSL_SYS_WIN32",
			"OPENSSL_BUILDING_OPENSSL",

			"ENGINESDIR=\".\"",
			"OPENSSLDIR=\".\"",
			"MODULESDIR=\".\""
		}

		excludes {
			"./crypto/ppccap.c",
			"./crypto/s390xcap.c",
			"./crypto/sparcv9cap.c",
			"./crypto/loongarchcap.c",
			"./crypto/ec/ecp_nistp256.c",
			"./crypto/ec/ecp_nistp224.c",
			"./crypto/ec/ecp_nistp521.c",
			"./crypto/ec/ecp_nistp384.c",
			"./crypto/poly1305/poly1305_ieee754.c",
			"./crypto/poly1305/poly1305_base2_44.c",

			"./**gcc**",
			"./**arm**",
			"./**sparc**",
			"./**LPdir**",

			"./crypto/**_vms.c",
			"./crypto/**_unix.c",

			"./crypto/sha/sha_ppc.c",
			"./crypto/aes/aes_cbc.c",
			"./crypto/des/ncbc_enc.c",
			"./crypto/rc4/rc4_skey.c",
			"./crypto/sha/keccak1600.c",
			"./crypto/aes/aes_x86core.c",
			"./crypto/chacha/chacha_ppc.c",
			"./crypto/camellia/camellia.c",
			"./crypto/poly1305/poly1305_ppc.c",
			
			"./ssl/record/methods/ktls_**.c",
		}

		files {
			"./ms/uplink.c"
		}

	filter { "system:windows", "files:**mkbuildinf.pl" }
		buildmessage "Generating build info"

		buildcommands {
			"perl \"util\\mkbuildinf.pl\" \"MultiEngine-CmdLine\" \"VC-WIN64A\"> .\\crypto\\buildinf.h"
		}

		buildoutputs { ".\\crypto\\buildinf.h" }

	-- TODO: also other platforms
	filter { "system:windows", "files:**.h.in" }
		buildmessage "Generating %{file.basename}"

		buildcommands {
			"perl \"-I.\" \"-Iutil\\perl\" \"-Iproviders\\common\\der\" \"-Mconfigdata\" \"-MOpenSSL::paramnames\" \"-Moids_to_c\" \"util\\dofile.pl\" \"-omakefile\" %{file.relpath} > %{file.reldirectory}\\%{file.basename}"
		}

		buildoutputs { "%{file.reldirectory}\\%{file.basename}" }

	filter { "system:windows", "files:**x86_64.pl" }
		buildmessage "Compiling %{file.basename}.asm"

		buildcommands {
			"set ASM=ml64 && perl %{file.relpath} masm %{cfg.objdir}/%{file.basename}.asm && ml64 /c /Cp /Cx /nologo /Zi /Fo%{cfg.objdir}/%{file.basename}.obj %{cfg.objdir}/%{file.basename}.asm"
		}

		buildoutputs { "%{cfg.objdir}/%{file.basename}.asm", "%{cfg.objdir}/%{file.basename}.obj" }

		


	