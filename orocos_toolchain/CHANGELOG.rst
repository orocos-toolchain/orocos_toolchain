^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changes, New Features, and Fixes for the Orocos Toolchain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Toolchain 2.9
=============

The Orocos Toolchain v2.9 release series mainly improved on the
correct execution of the Component updateHook() and allowing
extended configuration options when connecting Data Flow ports.


Important Caveats
-----------------

* The Orocos CMake macro orocos_use_package() does not longer
  automatically add the package to the CMake include
  directories. It is still picked up by the orocos_component()
  and related macros, just no longer by other targets built with
  the standard cmake commands. Most users should not notice a
  difference. This minor change was required to fix include
  directory ordering issues when rebuilding a package without
  a proper cleanup of the installation folder. For details, see
  https://github.com/orocos-toolchain/rtt/pull/85.

* updateHook() will now only be executed when an 'user' triggered
  event has happened, and no longer when internal bookkeeping
  of the ExeuctionEngine happens. For full details, see PR
  https://github.com/orocos-toolchain/rtt/pull/91.
  The motivation of this change was an older issue which reported
  that updateHook() was called too many times, and in unpredictable
  ways for the average user. The calling of updateHook() is now
  fully determined and under control of the user.

* RTT::base::ActivityInterface got a new pure virtual member
  function bool timeout() which you need to implement in case
  you created your own Activity implementation. See 
  https://github.com/orocos/rtt_ros_integration/pull/53 for
  an example of a solution.

* OCL XML deployments treats a ConnPolicy XML Property with
  the name "Default" as a special case. The values of the
  "Default" ConnPolicy will be used for each unspecified field
  in each subsequently created ConnPolicy in the current process.
  This also influences ConnPolicy defaults in the C++ code paths
  that have nothing to do with the XML deployment. It was introduced
  to change at run-time the default data flow configuration,
  which was introduced in 2.9, and still defaults to 2.8 semantics.

* For the `gnulinux` target, periodic components, timers or waiting on
  a condition variable are not affected by system clock adjustments anymore
  (e.g. due to NTP). Therefore the timestamp returned by
  ``RTT::os::TimeService::getNSecs()`` is also retrieved
  from a monotonic clock. Before, this method returned the real/wall time
  (as nanoseconds since the Unix epoch, 1 January 1970, 00:00:00 UTC).
  Only use the returned time for relative comparisons or for
  `RTT::os::Condition::wait_until(m, abs_time)`. See PR
  https://github.com/orocos-toolchain/rtt/pull/258. 

Improvements
------------

* updateHook() will now only be executed when an 'user' triggered
  event has happened, and no longer when internal bookkeeping
  of the ExeuctionEngine happens. For full detail, see PR
  https://github.com/orocos-toolchain/rtt/pull/91.
  Yes, it's also a major improvement.

* The RTT scripting re-added the Orocos v1 'Command', by emulating
  it when an Operation is called with the '.cmd()' suffix. See PR
  https://github.com/orocos-toolchain/rtt/pull/84.

* The RTT Data Flow implementation has been rewritten, in a fully
  backwards compatible way. It however adds powerful alternative 
  connection semantics which are often required in control
  applications. For all details, see PR https://github.com/orocos-toolchain/rtt/pull/114
  The robustness and flexibility of the Orocos Data Flow
  has improved tremendously in this release and should hold for the
  next years.
  It addresses all known data flow architecture issues for
  intra- and inter-process communication. User can choose to
  opt-in on the newly available connection policies, piecewise
  or change the process-wide default (see OCL XML deployments
  below as well). There is a broad motivation text linked by
  the above PR, but one of the major motivators was to have
  much better control and predictability over the sample-by-
  sample dataflow going on between RTT components.

* The CORBA Data Flow API now uses one-ways such that it performs
  much better on any network with latency. Also the connecting
  between RTT components over CORBA has been speed-up significantly
  due to the improvement of the introspection+discovery. See
  https://github.com/orocos-toolchain/rtt/pull/123 for all details.

Other API changes
-----------------

* The method `RTT::Property<T>::copy()` introduced in version 2.7
  to fix a memory leak in class `PropertyBag` has been removed in
  favor of an overload of `RTT::Property<T>::create()` that accepts
  a data source. See https://github.com/orocos-toolchain/rtt/pull/159.

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
