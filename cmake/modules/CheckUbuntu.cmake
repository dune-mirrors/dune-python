# .. cmake_module::
#
#    A module, that defines some additional variables about
#    the operating system, especially w.r.t. Ubuntu systems.
#    These are needed to work around nasty ubuntu bugs...
#
#    Defines the following variables:
#
#    :code:`SYSTEM_IS_UBUNTU`
#       Whether the current system is Ubuntu
#
#    :code:`UBUNTU_VERSION`
#       The Ubuntu version in the form YY.MM
#

set(SYSTEM_IS_UBUNTU False)
if(EXISTS /etc/dpkg/origins/ubuntu)
  set(SYSTEM_IS_UBUNTU True)
endif()

set(UBUNTU_VERSION "")
if(SYSTEM_IS_UBUNTU)
  file(STRINGS /etc/lsb-release output REGEX "^DISTRIB_RELEASE=[^\\n]+")
  string(REPLACE "DISTRIB_RELEASE=" "" UBUNTU_VERSION ${output})
  message("output: @${UBUNTU_VERSION}@")
endif()
