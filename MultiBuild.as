void main(MultiBuild::Workspace& workspace) {	
	auto project = workspace.create_project(".");
	auto properties = project.properties();

	properties.name("OpenSSL");
	properties.binary_object_kind(MultiBuild::BinaryObjectKind::eStaticLib);
	properties.license("./LICENSE.txt");
	properties.tags("use_header_only_mle");

	properties.project_includes({
		"zlib"
	});

	project.include_own_required_includes(true);
	project.add_required_project_include({
		"./include"
	});

	properties.files({
		"./ssl/**.h",
		"./ssl/**.c",
		"./crypto/**.h",
		"./crypto/**.c",

		"./providers/common/**.c",
		"./providers/implementations/ciphers/**.c",
		"./providers/implementations/digests/**.c",

		"./engines/e_capi.c",

		"./providers/**.h",
		"./providers/**.c",

		"./**.h.in",
		"./**x86_64.pl",
		"./crypto/**.c.in",
		"./providers/common/der/**.c.in",

		"./configdata.pm.in",
		"./util/mkbuildinf.pl",
		
		// Note: needed because generated non-obj files do not get taken into account
		"./crypto/params_idx.c",
		"./providers/common/der/der_digests_gen.c",
		"./providers/common/der/der_dsa_gen.c",
		"./providers/common/der/der_ec_gen.c",
		"./providers/common/der/der_ecx_gen.c",
		"./providers/common/der/der_rsa_gen.c",
		"./providers/common/der/der_sm2_gen.c",
		"./providers/common/der/der_wrap_gen.c"
	});

	properties.include_directories({
		".",
		"./crypto",
		"./crypto/",
		"./crypto/modes",
		"./crypto/include",
		"./crypto/ec/curve448",
		"./providers/common/include",
		"./crypto/ec/curve448/arch_32",
		"./providers/implementations/include"
	});

	properties.exclude_files({
		"./providers/legacyprov.c",
		"./crypto/ec/ecp_nistz256_table.c",
		"./crypto/rsa/rsa_acvp_test_params.c",
		"./providers/implementations/macs/blake2_mac_impl.c",
		"./providers/implementations/rands/seeding/rand_vms.c",
		"./providers/implementations/rands/seeding/rand_vxworks.c",

		"./crypto/md2/**",
		"./crypto/rc5/**",
		"./crypto/evp/**md2**",

		"./providers/fips/**",
		"./providers/common/**fips**.c",
		"./providers/implementations/**rc5**",
		"./providers/implementations/**md2**",

		"./**riscv**",

		// Note: dependencies not needed
		"./cloudflare-quiche/**",
		"./gost-engine/**",
		"./krb5/**",
		"./oqs-provider/**",
		"./pyca-cryptography/**",
		"./python-ecdsa/**",
		"./tlsfuzzer/**",
		"./tlslite-ng/**",
		"./wycheproof/**"
	});

	{
		MultiBuild::ScopedFilter _(workspace, "project.compiler:VisualCpp");
		properties.disable_warnings({ "4311", "4996", "4267", "4244", "4305", "4013", "4133", "4334", "4090" });
	}

	{
		MultiBuild::ScopedFilter _(workspace, "config.platform:Windows");
		properties.defines({
			"WIN32_LEAN_AND_MEAN",
			"OPENSSL_PIC",
			"L_ENDIAN",
			"OPENSSL_SYS_WIN32",
			"OPENSSL_BUILDING_OPENSSL",

			"ENGINESDIR=\".\"",
			"OPENSSLDIR=\".\"",
			"MODULESDIR=\".\""
		});

		properties.exclude_files({
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

			"./crypto/ec/ecp_ppc.c",
			"./crypto/sha/sha_ppc.c",
			"./crypto/aes/aes_cbc.c",
			"./crypto/rc4/rc4_enc.c",
			"./crypto/aes/aes_core.c",
			"./crypto/des/ncbc_enc.c",
			"./crypto/rc4/rc4_skey.c",
			"./crypto/sha/keccak1600.c",
			"./crypto/aes/aes_x86core.c",
			"./crypto/whrlpool/wp_block.c",
			"./crypto/chacha/chacha_ppc.c",
			"./crypto/chacha/chacha_enc.c",
			"./crypto/camellia/camellia.c",
			"./crypto/camellia/cmll_cbc.c",
			"./crypto/poly1305/poly1305_ppc.c",
			
			"./ssl/record/methods/ktls_**.c"
		});

		properties.files({
			"./ms/uplink.c",
			"./providers/implementations/rands/seeding/rand_win.c"
		});
	}

	{
		MultiBuild::ScopedFilter _(workspace, "config.platform:Windows && file:**configdata.pm.in");

		properties.build_message("Configuring");
		properties.build_commands("perl Configure VC-WIN64A --prefix={:project.target_dir --openssldir={:project.target_dir}");
		properties.build_outputs(".\\configdata.pm");
	}

	{
		MultiBuild::ScopedFilter _(workspace, "config.platform:Windows && file:**mkbuildinf.pl");

		properties.build_message("Generating build info");
		properties.build_commands("perl \"-I.\" \"util\\mkbuildinf.pl\" \"MultiEngine-CmdLine\" \"VC-WIN64A\"> .\\crypto\\buildinf.h");
		properties.build_outputs(".\\crypto\\buildinf.h");
	}

	{
		MultiBuild::ScopedFilter _(workspace, "config.platform:Windows && file:**.h.in");

		properties.build_message("Generating {:file.stem}");
		properties.build_commands("perl \"-I.\" \"-Iutil\\perl\" \"-Iproviders\\common\\der\" \"-Mconfigdata\" \"-MOpenSSL::paramnames\" \"-Moids_to_c\" \"util\\dofile.pl\" \"-omakefile\" {:file.path} > {:file.location}\\{:file.stem}");
		properties.build_outputs("{:file.location}\\{:file.stem}");
	}

	{
		MultiBuild::ScopedFilter _(workspace, "config.platform:Windows && file:**.c.in");

		properties.build_message("Generating {:file.stem}");
		properties.build_commands("perl \"-I.\" \"-Iutil\\perl\" \"-Iproviders\\common\\der\" \"-Mconfigdata\" \"-MOpenSSL::paramnames\" \"-Moids_to_c\" \"util\\dofile.pl\" \"-omakefile\" {:file.path} > {:file.location}\\{:file.stem}");
		properties.build_outputs("{:file.location}\\{:file.stem}");
	}

	{
		MultiBuild::ScopedFilter _(workspace, "config.platform:Windows && file:**x86_64.pl");

		properties.build_message("Compiling {:file.stem}.asm");
		properties.build_commands("set ASM=ml64 && perl {:file.path} masm {:project.obj_dir}/{:file.stem}.asm && ml64 /c /Cp /Cx /nologo /Zi /Fo{:project.obj_dir}/{:file.stem}.obj {:project.obj_dir}/{:file.stem}.asm");
		properties.build_outputs({ "{project.obj_dir}/{:file.stem}.asm", "{project.obj_dir}/{:file.stem}.obj" }	);
	}
}