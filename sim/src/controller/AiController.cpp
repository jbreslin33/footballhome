// footballhome sim - AiController skeleton implementation
//
// M0: always idle. M3+ will replace this with utility-AI selection.

#include "controller/AiController.hpp"

namespace fh::sim::controller {

Intent AiController::decide(const awareness::AwarenessView& view, SlotId self)
{
    (void)view;
    (void)self;
    return idle();
}

} // namespace fh::sim::controller
