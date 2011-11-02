# Setup the search paths
xmake_include_directories(ATHENA_FRAMEWORK)
include_directories("${SAORI_SOURCE_DIR}/include"
                    "${SAORI_SOURCE_DIR}/dependencies"
                    "${SAORI_SOURCE_DIR}/dependencies/include"
)

# List the source files
set(SRCS main.mm
         SaoriAppDelegate.mm
         Context.mm
         MeshViewerState.mm
         controls/View3D.mm
)

# List the Interface Builder Files
set(XIBS Application
)

# List the link directories
xmake_link_directories(ATHENA_FRAMEWORK)

# Create and link the executable
add_executable(saori ${SRCS})
xmake_target_link_libraries(saori ATHENA_FRAMEWORK)

# Create .app bundle
set_property(TARGET saori PROPERTY MACOSX_BUNDLE TRUE)

set_target_properties(saori PROPERTIES MACOSX_BUNDLE_INFO_PLIST "${SAORI_SOURCE_DIR}/resources/Info.plist")

set (CONTENTS_PATH "${ATHENA_BINARY_DIR}/bin/Saori.app/Contents")

# Make sure we can find the 'ibtool' program. If we can NOT find it we
# skip generation of this project
find_program(IBTOOL ibtool HINTS "/usr/bin" "${OSX_DEVELOPER_ROOT}/usr/bin")
if (${IBTOOL} STREQUAL "IBTOOL-NOTFOUND")
  message(SEND_ERROR "ibtool can not be found and is needed to compile the .xib files. It should have been installed with 
                    the Apple developer tools. The default system paths were searched in addition to ${OSX_DEVELOPER_ROOT}/usr/bin")
endif()

# Make sure the 'Resources' Directory is correctly created before we build
add_custom_command(TARGET saori PRE_BUILD
                   COMMAND mkdir -p "${CONTENTS_PATH}/Resources")

# Compile the .xib files using the 'ibtool' program with the destination being the app package
foreach(xib ${XIBS})
    add_custom_command(TARGET saori POST_BUILD 
                       COMMAND ${IBTOOL} --errors --warnings --notices --output-format human-readable-text 
                               --compile "${CONTENTS_PATH}/Resources/${xib}.nib"
                               "${SAORI_SOURCE_DIR}/resources/${xib}.xib"
                       COMMENT "Compiling resources/${xib}.xib")

endforeach()

# Symlink the Frameworks
add_custom_command(TARGET saori POST_BUILD
  COMMAND mkdir ARGS -p ${CONTENTS_PATH}/Frameworks
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/Ogre.framework ${CONTENTS_PATH}/Frameworks/
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/Cg.framework ${CONTENTS_PATH}/Frameworks/
)

# Symlink the configuration files
add_custom_command(TARGET saori POST_BUILD
  COMMAND mkdir ARGS -p ${CONTENTS_PATH}/Resources
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/plugins.cfg ${CONTENTS_PATH}/Resources/
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/resources.cfg ${CONTENTS_PATH}/Resources/
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/athena.cfg ${CONTENTS_PATH}/Resources/
)

# Symlink the cursors & icons
add_custom_command(TARGET saori POST_BUILD
  COMMAND mkdir ARGS -p ${CONTENTS_PATH}/Resources
  COMMAND ln ARGS -s -F -h ${SAORI_SOURCE_DIR}/resources/Cursors/ ${CONTENTS_PATH}/Resources/Cursors
  COMMAND ln ARGS -s -f ${SAORI_SOURCE_DIR}/resources/Icons/Icon_Solid.png ${CONTENTS_PATH}/Resources/
  COMMAND ln ARGS -s -f ${SAORI_SOURCE_DIR}/resources/Icons/Icon_Wireframe.png ${CONTENTS_PATH}/Resources/
  COMMAND ln ARGS -s -f ${SAORI_SOURCE_DIR}/resources/Icons/Icon_Points.png ${CONTENTS_PATH}/Resources/
  COMMAND ln ARGS -s -f ${SAORI_SOURCE_DIR}/resources/Icons/Icon_Light.png ${CONTENTS_PATH}/Resources/
)

# Symlink the plugins
add_custom_command(TARGET saori POST_BUILD
  COMMAND mkdir ARGS -p ${CONTENTS_PATH}/Plugins
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/RenderSystem_GL.dylib ${CONTENTS_PATH}/Plugins/
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/Plugin_CgProgramManager.dylib ${CONTENTS_PATH}/Plugins/
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/Plugin_OctreeSceneManager.dylib ${CONTENTS_PATH}/Plugins/
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/Plugin_ParticleFX.dylib ${CONTENTS_PATH}/Plugins/
)

# Symlink the dynamic libraries
add_custom_command(TARGET saori POST_BUILD
  COMMAND mkdir ARGS -p ${CONTENTS_PATH}/Libraries
  COMMAND ln ARGS -s -f ${SAORI_BINARY_DIR}/bin/libAthena.dylib ${CONTENTS_PATH}/Libraries/
)

# Set the RPATH
set_target_properties(saori PROPERTIES LINK_FLAGS "${XMAKE_ATHENA_FRAMEWORK_LINK_FLAGS} -Wl,-rpath,@loader_path/../Frameworks,-rpath,@loader_path/../Libraries")
