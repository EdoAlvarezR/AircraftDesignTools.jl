#=##############################################################################
# DESCRIPTION
    Definition of physical components.

# AUTHORSHIP
  * Author    : Eduardo J. Alvarez
  * Email     : Edo.AlvarezR@gmail.com
  * Created   : Jul 2019
  * License   : AGPL-3.0
=###############################################################################

################################################################################
# ABSTRACT COMPONENT TYPE
################################################################################
"""
    `AbstractComponent{T1, T2}`

  Implementations of AbstractComponent are expected to have the following fields
  * `name::String`                : Name of this component
  * `subcomponents`               : Subcomponents that make this component
  * `id::Int`                     : Component number identifier
  * `O::Array{T1, 1}`             : Origin of object coordinate system
  * `Oaxis::Array{T2, 2}`         : Orientation of coordinate sytem
  * `description::String`         : Useful description
  * `comments::String`            : Vent about your life here
  * `vendor::String`              : Vendor information

  and the following functions

```julia
    "Returns the number of items that make this component"
    Base.length(cmp::Component) = ...
```
"""
abstract type AbstractComponent{T1, T2} end


##### COMMON FUNCTIONS  ########################################################
"""
    `clone(component, O, Oaxis)`
Returns a clone of this component in the new location `O` and orientation `Oaxis`
"""
function clone(cmp::CompType, O::Array{T1, 1}, Oaxis::Array{T2, 1}
                    ) where {CompType<:AbstractComponent, T1<:RType, T2<:RType}
    return CompType(cmp.name, cmp.subcomponents;
                        id=cmp.id,
                        O=O, Oaxis=Oaxis,
                        description=cmp.description, comments=cmp.comments,
                        vendor=cmp.vendor)
end

"`clone(component, O)`"
clone(cmp::AbstractComponent, O::Array{T, 1}) where T = clone(cmp, O, cmp.Oaxis)

"`clone(component, Oaxis)`"
clone(cmp::AbstractComponent, Oaxis::Array{T, 2}) where T = clone(cmp, cmp.O, Oaxis)

"`clone(component)`"
clone(cmp::AbstractComponent) = clone(cmp, cmp.O, cmp.Oaxis)

##### COMMON INTERNAL FUNCTIONS  ###############################################
Base.length(cmp::AbstractComponent) = length(cmp.subcomponent)

##### END OF ABSTRACT COMPONENT ################################################


################################################################################
# COMPONENT IMPLEMENTATION TYPES
################################################################################
"""
    `Component(name::String, object::ObjectTypes; optargs...) <:
AbstractComponent`

Defines an object placed at a location and orientation in space.

# OPTIONAL ARGUMENTS
* `id::Int`                     : Component number identifier
* `O::Array{Real, 1}`           : Origin of object coordinate system
* `Oaxis::Array{Real, 2}`       : Orientation of coordinate sytem
* `description::String`         : Useful description
* `comments::String`            : Vent about your life here
* `vendor::String`              : Vendor information
"""
immutable Component{T1<:RType, T2<:RType} <: AbstractComponent{T1, T2}

    # User inputs
    name::String                        # Name of component
    subcomponents::ObjectTypes          # Mass and geometric of this component

    # Optional inputs
    id::Int                             # Component number identifier
    O::Array{T1, 1}                     # Origin of object coordinate system
    Oaxis::Array{T2, 2}                 # Orientation of coordinate sytem
    description::String                 # Useful description
    comments::String                    # Vent about your life here
    vendor::String                      # Vendor information

    Component{T1,T2}(  name, subcomponents;
                id=-1,
                O=zeros(T1, 3), Oaxis=eye(T2, 3),
                description="", comments="", vendor=""
             ) where {T1,T2} = new(
                name, subcomponents,
                id,
                O, Oaxis,
                description, comments, vendor
             )
end

# Constructor that identifies parametric types automatically
Component(name, subcomponents;
          O::Array{T1, 1}=zeros(Float64, 3), Oaxis::Array{T2, 2}=eye(Float64, 3),
          optargs...) where {T1, T2} = Component{T1, T2}(
                                    name, subcomponents; O=O, Oaxis=Oaxis, optargs...)




"""
    `System(name::String, components::Array{C, 1}; optargs...) where
{C<:AbstractComponent} <: AbstractComponent`

Defines a system make out of components. This allows for recursive definition of
systems holding other systems as subcomponents.

# OPTIONAL ARGUMENTS
* `id::Int`                     : System number identifier
* `O::Array{Real, 1}`           : Origin of system coordinate system
* `Oaxis::Array{Real, 2}`       : Orientation of coordinate sytem
* `description::String`         : Useful description
* `comments::String`            : Vent about your life here
* `vendor::String`              : Vendor information
"""
immutable System{C<:AbstractComponent, T1<:RType, T2<:RType} <: AbstractComponent{T1, T2}

    # User inputs
    name::String                        # Name of component
    subcomponents::Array{C, 1}          # Components that make this system

    # Optional inputs
    id::Int                             # Component number identifier
    O::Array{T1, 1}                     # Origin of subcomponents coordinate system
    Oaxis::Array{T2, 2}                 # Orientation of coordinate sytem
    description::String                 # Useful description
    comments::String                    # Vent about your life here
    vendor::String                      # Vendor information

    System{C,T1,T2}(  name, subcomponents;
                id=-1,
                O=zeros(T1, 3), Oaxis=eye(T2, 3),
                description="", comments="", vendor=""
             ) where {C,T1,T2} = new(
                name, subcomponents,
                id,
                O, Oaxis,
                description, comments, vendor
             )
end

# Constructor that identifies parametric types automatically
System(name, subcomponents;
          O::Array{T1, 1}=zeros(Float64, 3), Oaxis::Array{T2, 2}=eye(Float64, 3),
          optargs...) where {T1, T2} = System{eltype(subcomponents), T1, T2}(
                            name, subcomponents; O=O, Oaxis=Oaxis, optargs...)
##### END OF COMPONENT IMPLEMENTATIONS #########################################

# Declares implementations of AbstractComponent
const ComponentTypes = Union{Component, System}
