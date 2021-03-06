version: @VERSION@.{build}

branches:
  except:
    - gh-pages

environment:
  CTEST_OUTPUT_ON_FAILURE: 1
  SDL2_VERSION: 2.0.5
  MINGW_PATH: C:\MinGW
  SDLDIR: C:\MinGW

platform:
  - x86

install:
  # CMake refuses to generate MinGW Makefiles if sh.exe is in the Path
  - ps: Get-Command sh.exe -All | Remove-Item
  - IF NOT EXIST %APPVEYOR_BUILD_FOLDER%\SDL2-devel-%SDL2_VERSION%-mingw.tar.gz appveyor DownloadFile http://libsdl.org/release/SDL2-devel-%SDL2_VERSION%-mingw.tar.gz
  - 7z x SDL2-devel-%SDL2_VERSION%-mingw.tar.gz -so | 7z x -si -ttar -oC:\
  - echo y | xcopy C:\SDL2-%SDL2_VERSION%\i686-w64-mingw32\* %MINGW_PATH%\ /S
  - IF NOT EXIST %APPVEYOR_BUILD_FOLDER%\SDL2_mixer-devel-2.0.1-mingw.tar.gz appveyor DownloadFile https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-devel-2.0.1-mingw.tar.gz
  - 7z x SDL2_mixer-devel-2.0.1-mingw.tar.gz -so | 7z x -si -ttar -oC:\
  - echo y | xcopy C:\SDL2_mixer-2.0.1\i686-w64-mingw32\* %MINGW_PATH%\ /S
  - IF NOT EXIST %APPVEYOR_BUILD_FOLDER%\SDL2_image-devel-2.0.1-mingw.tar.gz appveyor DownloadFile https://www.libsdl.org/projects/SDL_image/release/SDL2_image-devel-2.0.1-mingw.tar.gz
  - 7z x SDL2_image-devel-2.0.1-mingw.tar.gz -so | 7z x -si -ttar -oC:\
  - echo y | xcopy C:\SDL2_image-2.0.1\i686-w64-mingw32\* %MINGW_PATH%\ /S

before_build:
  - .\build\windows\get-sdl2-dlls.bat dll "appveyor DownloadFile"
  - set Path=%MINGW_PATH%\bin;%Path%
  - if "%APPVEYOR_REPO_TAG%"=="true" (set CMAKE_BUILD_TYPE=Release) else (set CMAKE_BUILD_TYPE=Debug)
  - cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% -D CMAKE_C_COMPILER=mingw32-gcc.exe -D CMAKE_MAKE_PROGRAM=mingw32-make.exe .

build_script:
  - mingw32-make

after_build:
  - mingw32-make test
  - mingw32-make package
  - dir

cache:
- SDL2-devel-%SDL2_VERSION%-mingw.tar.gz
- SDL2_mixer-devel-2.0.1-mingw.tar.gz
- SDL2_image-devel-2.0.1-mingw.tar.gz
- dir\SDL2-%SDL2_VERSION%-win32-x86.zip
- dir\SDL2_image-2.0.1-win32-x86.zip
- dir\SDL2_mixer-2.0.1-win32-x86.zip

artifacts:
  - path: /.\C-Dogs*.exe/

deploy:
  provider: GitHub
  description: ''
  auth_token:
    secure: Ap9XXGG/1cyV9hpat7EaYxZHBt/VWdH82Bx+nIugdJ1Dh3I9e8OP4L/IXkadUjdR
  prerelease: false
  force_update: true 	#to be in piece with Travis CI
  on:
    appveyor_repo_tag: true
