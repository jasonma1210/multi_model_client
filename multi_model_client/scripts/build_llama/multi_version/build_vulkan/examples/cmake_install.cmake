# Install script for directory: /Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/llama.cpp/examples

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Users/jianma/Library/Android/sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-objdump")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/baby-llama/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/batched/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/batched-bench/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/beam-search/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/benchmark/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/convert-llama2c-to-ggml/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/embedding/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/eval-callback/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/finetune/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/gritlm/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/gguf-split/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/infill/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/llama-bench/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/llava/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/main/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/tokenize/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/parallel/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/perplexity/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/quantize/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/quantize-stats/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/retrieval/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/save-load-state/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/simple/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/passkey/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/speculative/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/lookahead/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/lookup/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/gguf/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/train-text-from-scratch/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/imatrix/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/server/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/export-lora/cmake_install.cmake")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts/build_llama/multi_version/build_vulkan/examples/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
