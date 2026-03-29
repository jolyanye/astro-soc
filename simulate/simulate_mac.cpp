#include <cstdint>
#include <cstddef>

int32_t simulate_mac(int8_t weight, int8_t act, int32_t current_accum) {
    if (act == 0) {
        return current_accum;
    }
    int16_t mult_res = (int16_t)weight * (int16_t)act;
    return current_accum + mult_res;
}

int32_t vector_dot_product(const int8_t* weights, const int8_t* activations, size_t length) {
    int32_t accumulator = 0;
    for (size_t i = 0; i < length; i++) {
        accumulator = simulate_mac((int8_t)weights[i], (int8_t)activations[i], accumulator);
    }
    return accumulator;
}