//
//  nob_defer.h
//  HomePwner
//
//  Created by Hanguang on 4/21/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#ifndef nob_defer_h
#define nob_defer_h

// some helper declarations
#define _nob_macro_concat(a, b) a##b
#define nob_macro_concat(a, b) _nob_macro_concat(a, b)
typedef void(^nob_defer_block_t)();
NS_INLINE void nob_deferFunc(__strong nob_defer_block_t *blockRef)
{
    nob_defer_block_t actualBlock = *blockRef;
    actualBlock();
}

// the core macro
#define nob_defer(deferBlock) \
__strong nob_defer_block_t nob_macro_concat(__nob_stack_defer_block_, __LINE__) __attribute__((cleanup(nob_deferFunc), unused)) = deferBlock

#endif /* nob_defer_h */
