//
// Copyright 2012 Josh Blum
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with io_sig program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef INCLUDED_LIBGNURADIO_ELEMENT_IMPL_HPP
#define INCLUDED_LIBGNURADIO_ELEMENT_IMPL_HPP

#include <tsbe/block.hpp>
#include <tsbe/topology.hpp>
#include <tsbe/executor.hpp>
#include <gnuradio/element.hpp>
#include <gnuradio/block.hpp>
#include <gr_types.h>
#include <vector>
#include <iostream>

#define HERE() std::cerr << __FILE__ << ":" << __LINE__ << std::endl << std::flush;
#define VAR(x) std::cout << #x << " = " << (x) << std::endl << std::flush;

static inline unsigned long myulround(const double x)
{
    return (unsigned long)(x + 0.5);
}

static inline unsigned long long myullround(const double x)
{
    return (unsigned long long)(x + 0.5);
}

struct TopBlockMessage
{
    enum
    {
        UPDATE,
        ACTIVE,
        INERT,
        HINT,
    } what;
    size_t hint;
};

namespace gnuradio
{

struct ElementImpl
{
    //stuff for when its a block
    std::string name;
    long unique_id;

    //per port properties
    std::vector<size_t> input_items_sizes;
    std::vector<size_t> output_items_sizes;
    IOSignature input_signature;
    IOSignature output_signature;
    std::vector<size_t> input_history_items;
    std::vector<size_t> output_multiple_items;

    //keeps track of production
    std::vector<uint64_t> items_consumed;
    std::vector<uint64_t> items_produced;

    //work buffers
    gr_vector_const_void_star work_input_items;
    gr_vector_void_star work_output_items;
    gr_vector_int work_ninput_items;
    Block::InputItems input_items;
    Block::OutputItems output_items;
    std::vector<size_t> produce_items;
    std::vector<size_t> consume_items;

    //special buffer for dealing with history
    std::vector<tsbe::Buffer> history_buffs;

    //tag tracking
    std::vector<bool> input_tags_changed;
    std::vector<std::vector<Tag> > input_tags;
    std::vector<std::vector<Tag> > output_tags;
    Block::tag_propagation_policy_t tag_prop_policy;

    //topological things
    tsbe::Block block;
    tsbe::Topology topology;
    tsbe::Executor executor;
    const tsbe::Element &get_elem(void) const
    {
        if (block) return block;
        return topology;
    }
    //gets the handlers access for forecast and work
    Block *block_ptr;
    size_t hint; //some kind of allocation hint

    //handlers
    void handle_port_msg(const size_t, const tsbe::Wax &);
    void topology_update(const tsbe::TaskInterface &, const tsbe::Wax &);
    void handle_allocation(const tsbe::TaskInterface &);
    void handle_task(const tsbe::TaskInterface &);

    //is the fg running?
    bool active;

    //rate settings
    bool enble_fixed_rate;
    double relative_rate;
};

} //namespace gnuradio

#endif /*INCLUDED_LIBGNURADIO_ELEMENT_IMPL_HPP*/
