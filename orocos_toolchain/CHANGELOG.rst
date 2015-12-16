^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changes, New Features, and Fixes for the Orocos Toolchain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Toolchain 2.9
=============

The Orocos Toolchain v2.9 release series mainly improved on the
correct execution of the Component updateHook() and allowing
extended configuration options when connecting Data Flow ports.

There was also a big change in the RTT StateMachine execution
semantics on a cycle-by-cycle basis, see the Caveats.

Important Caveats
-----------------

* updateHook() will now only be executed when an 'user' triggered
  event has happened, and no longer when internal bookkeeping
  of the ExeuctionEngine happens. For full detail, see PR
  https://github.com/orocos-toolchain/rtt/pull/91

* Each cycle of an RTT State Machine now starts with executing
  the run {} program instead of first checking the transitions.
  Previously, run {} was executed in the same cycle as the
  exit {} + entry {} programs, in case exit {} + entry {} 
  did not yield. 
  Since event operation transitions are ignored during entry {}, it is
  impossible to respond to event operations which would take one cycle
  after run {} to be processed. In addition, this also means that
  in this setting, a default transition would always be taken after
  run {} if the other transitions are all event transitions.
  This change needs broader discussion in the community and
  all comments can be tracked in this issue:
  

Improvements
------------

* updateHook() will now only be executed when an 'user' triggered
  event has happened, and no longer when internal bookkeeping
  of the ExeuctionEngine happens. For full detail, see PR
  https://github.com/orocos-toolchain/rtt/pull/91
  Yes, it's also a major improvement.

* The RTT scripting re-added the Orocos v1 'Command', by emulating
  it when an Operation is called with the '.cmd()' suffix. See PR
  https://github.com/orocos-toolchain/rtt/pull/84

* The RTT Data Flow implementation has been rewritten, in a fully
  backwards compatible way. It however adds powerful alternative 
  connection semantics which are often required in control
  applications. For all details, see PR https://github.com/orocos-toolchain/rtt/pull/114
  The robustness and flexibility of the Orocos Data Flow
  has improved tremendously in this release and should hold for the
  next years.

Detailed Changelogs
-------------------

RTT https://github.com/orocos-toolchain/rtt/compare/toolchain-2.8...toolchain-2.9

OCL https://github.com/orocos-toolchain/ocl/compare/toolchain-2.8...toolchain-2.9

orogen https://github.com/orocos-toolchain/orogen/compare/toolchain-2.8...toolchain-2.9

autoproj https://github.com/orocos-toolchain/autoproj/compare/toolchain-2.8...toolchain-2.9

Toolchain 2.8
=============

The Orocos Toolchain v2.8 release series mainly improved on the
execution of various activities and control of the threads in RTT.


Important Caveats
-----------------

* RTT::SendStatus now also has a 'CollectFailure' enum value 
  (without changing the existing enum integer values).

* There were changes to the RTT StateMachine execution flow
  that may influence existing state machine scripts in case
  they are using the event operations introduced in v2.7.0.
  These changes were required because the event operation
  transition programs could execute asynchronously with respect
  to the State Machine.

Improvements
------------

* Better support for executing RTT::extras::SlaveActivity, especially
  for calling Operations, where the Operation is executed by the master
  component and not by the slave component in order to avoid deadlocks.

* RTT allows to replace boost::bind with cpp11 std::bind, but only
  when compiling RTT. This needs more work in next releases.

* Orocos-RTT CMake macros added DESTDIR support.

* RTT::Activity got an extra constructor for running non periodic
  RunnableInterfaces in a given scheduler+priority setting.

* There was another round of improvements to RTT::extras::FileDescriptorActivity
  in order to work correctly in combination with RTT::extras::SlaveActivity.

* RTT::extras::FileDescriptorSimulationActivity allows to simulate 
  file descriptor activities in unit tests. This is however incomplete
  and will be completed in RTT 2.9 when the updateHook() updates have been
  merged.

* RTT::Timer class has been cleaned up for correctness in corner cases
  and the waitFor() methods have been implemented.

* RTT Threads now allow to wait for Absolute time or Relative time in
  case of periodic threads.

* An RTT cmake flag has been added to not emit the CORBA IOR to cerr and file
  when the CORBA transport does not find the naming service.



Detailed Changelogs
-------------------

RTT https://github.com/orocos-toolchain/rtt/compare/toolchain-2.7...toolchain-2.8

OCL https://github.com/orocos-toolchain/ocl/compare/toolchain-2.7...toolchain-2.8

orogen https://github.com/orocos-toolchain/orogen/compare/toolchain-2.7...toolchain-2.8

autoproj https://github.com/orocos-toolchain/autoproj/compare/toolchain-2.7...toolchain-2.8


Toolchain 2.7
=============

The Orocos Toolchain v2.7 release series mainly improved on the cmake building
side and removing all the ROS interactions. It also added features and improvements
proposed by the community.

Important Caveats
-----------------

* There were changes in the RTT::TaskContext API, where RTT::ServiceRequester
  became a shared_ptr and getName() became const. ServiceRequester
  is still considered an experimental feature.

* The RTT::ComponentLoader has been changed to be again independent
  to ROS and the rtt_ros_integration package manages importing ROS
  packages.

* RTT::FileDescriptorActivity was extended with timeouts at micro
  second resolution.

* The RTT DataFlow.idl takes an extra argument in channelReady() in order
  to pass on the connection policy, which is required for correct
  channel construction.

Improvements
------------

* The main change in this release is the cleanup that happened
  in the Orocos RTT CMake macros, which no longer behave differently
  when the ROS_PACKAGE_PATH or ROS_ROOT has been set. Version 2.6
  and earlier switched to a rosbuild layout, which proved to be
  undesirable. We still detect a CATKIN or rosmake build
  in case these tools are used and marked as such in the CMakeLists.txt
  files.

* Signalling operations have been introduced to allow adding multiple callbacks
  to operations, in addition to calling the operation's user function.
  The RTT scripting state machines use this mechanism to respond to
  calls on the Service interface.

* Logging the RTT logger to log4cpp was added and can be enabled
  at using a cmake flag in RTT.

* The thread of the RTT::GlobalEngine can be configured during instantiation.

* Loading and Storing RTT::Service properties has been added to the 
  RTT::MarshallingService.

* RTT::os::Thread now provides a member function to set the stop() timeout.

* There were several fixes to RTT::scripting for correct execution of
  OwnThread / ClientThread operations, as well as parser improvements.

* RTT::rt_string was added to the RTT CORBA transport.

* The RTT mqueue transport is more relaxed to accepting types
  with virtual tables, in case no memcpy is used to marshall.

Detailed Changelogs
-------------------

RTT https://github.com/orocos-toolchain/rtt/compare/toolchain-2.6...toolchain-2.7

OCL https://github.com/orocos-toolchain/ocl/compare/toolchain-2.6...toolchain-2.7

orogen https://github.com/orocos-toolchain/orogen/compare/toolchain-2.6...toolchain-2.7

autoproj https://github.com/orocos-toolchain/autoproj/compare/toolchain-2.6...toolchain-2.7


Previous Versions
=================

link to orocos-rtt-changes up to v2.6
