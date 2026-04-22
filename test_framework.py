import sys
import testboy.testboy as testboy


@testboy.register_hook(id=1)
def foo(boy):
    print(boy.register_file.PC)
    print("olala")


testboy.run_test("build/test_live_block_in_hl.gb")
