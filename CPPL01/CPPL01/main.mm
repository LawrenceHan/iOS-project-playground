//
//  main.m
//  CPPL01
//
//  Created by Hanguang on 10/3/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <iostream>
#include "Sales_item.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
        std::cout << "Enter two numbers:" << std::endl;
        int v1 = 0, v2 = 0;
        std::cin >> v1 >> v2;
        std::cout << "The sum of " << v1 << " and " << v2
        << " is " << v1 + v2 << std::endl;
        */
        
        /*
        int sum = 0, value = 0;
        while (std::cin >> value) {
            sum += value;
        }
        std::cout << "Sum is: " << sum << std::endl;
        */
        
        /*
        int currVal = 0, val = 0;
        if (std::cin >> currVal) {
            int cnt = 1;
            while (std::cin >> val) {
                if (val == currVal) {
                    ++cnt;
                } else {
                    std::cout << currVal << " occurs " << cnt << " times" << std::endl;
                    currVal = val;
                    cnt = 1;
                }
            }
            
            std::cout << currVal << " occurs " << cnt << " times" << std::endl;
        }
         */
        
        /*
        Sales_item total;
        if (std::cin >> total) {
            Sales_item trans;
            while (std::cin >> trans) {
                if (total.isbn() == trans.isbn()) {
                    total += trans;
                } else {
                    std::cout << total << std::endl;
                    total = trans;
                }
            }
            std::cout << total << std::endl;
        } else {
            std::cerr << "No data?!" << std::endl;
        }
         */
        
        
    }
    return 0;
}
