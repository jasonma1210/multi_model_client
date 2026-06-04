# CMake generated Testfile for 
# Source directory: /Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/llama.cpp/examples/eval-callback
# Build directory: /Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_generic/examples/eval-callback
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(test-eval-callback "/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_generic/bin/eval-callback" "--hf-repo" "ggml-org/models" "--hf-file" "tinyllamas/stories260K.gguf" "--model" "stories260K.gguf" "--prompt" "hello" "--seed" "42" "-ngl" "0")
set_tests_properties(test-eval-callback PROPERTIES  LABELS "eval-callback;curl" _BACKTRACE_TRIPLES "/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/llama.cpp/examples/eval-callback/CMakeLists.txt;8;add_test;/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/llama.cpp/examples/eval-callback/CMakeLists.txt;0;")
