/*
    Copyright 2015-2024 Clément Gallet <clement.gallet@ens-lyon.org>

    This file is part of libTAS.

    libTAS is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    libTAS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with libTAS.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "pulseaudio.h"

#include "GlobalState.h"
#include "logging.h"
#include "hook.h"

namespace libtas {

/* Even with all the hooks of other audio backends, sometimes games just use
 * pulseaudio directly (e.g. GM:S from 2024). In that case, we return NULL when
 * attempting to create the first object, so that hopefully it will try another
 * audio backend that we support. */

pa_mainloop* pa_mainloop_new(void)
{
    RETURN_IF_NATIVE(pa_mainloop_new, (), "libpulse.so.0");
    LOGTRACE(LCF_SOUND);
    return nullptr;
}

pa_threaded_mainloop* pa_threaded_mainloop_new(void)
{
    RETURN_IF_NATIVE(pa_threaded_mainloop_new, (), "libpulse.so.0");
    LOGTRACE(LCF_SOUND);
    return nullptr;
}

}
