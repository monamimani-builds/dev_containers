#include <iostream>
#include <vector>
#include <numeric>
#include <ranges>

int main() {
    auto nums = std::vector<int>{1, 2, 3, 4, 5};
    auto squared = nums | std::views::transform([](int n) { return n * n; });
    
    int sum = 0;
    for (int n : squared) {
        sum += n;
    }
    
    std::cout << "Sum of squares: " << sum << std::endl;

    return 0;
}
