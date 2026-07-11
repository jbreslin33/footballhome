// footballhome sim - HumanController implementation

#include "controller/HumanController.hpp"

namespace fh::sim::controller {

Intent HumanController::decide(const awareness::AwarenessView& view,
                               SlotId self)
{
    // AwarenessView is not consulted — a human already sees the pitch on
    // their screen. self is only used by AI controllers. Both are unused
    // by design.
    (void)view;
    (void)self;
    return latest_;
}

} // namespace fh::sim::controller
