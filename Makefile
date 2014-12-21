GNATMAKE=gnatmake -gnatv -p -P

GNATCLEAN=gnatclean -P

build_src:
	$(GNATMAKE) opus_ada_lib.gpr -Xbuild=release

build_src_debug:
	$(GNATMAKE) opus_ada_lib.gpr -Xbuild=debug

clean_src:
	$(GNATCLEAN) opus_ada_lib.gpr

build_unit_tests:
	$(GNATMAKE) test/unit/unit_tests.gpr

clean_unit_tests:
	$(GNATCLEAN) test/unit/unit_tests.gpr

run_unit_tests:
	./test/unit/test_bindings

build: build_src

test: build_unit_tests

clean: clean_src clean_unit_tests
