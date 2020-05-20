//
//  secinit_interpose.c
//  secinit_interpose
//
//  Created by Saagar Jha on 1/20/20.
//  Copyright © 2020 Saagar Jha. All rights reserved.
//

void _libsecinit_initializer(void);

void overriden__libsecinit_initializer(void) {
}

__attribute__((used, section("__DATA,__interpose"))) static struct {
	void (*overriden__libsecinit_initializer)(void);
	void (*_libsecinit_initializer)(void);
} _libsecinit_initializer_interpose = {overriden__libsecinit_initializer, _libsecinit_initializer};
