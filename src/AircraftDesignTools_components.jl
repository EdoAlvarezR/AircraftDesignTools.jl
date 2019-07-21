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
# COMPONENT TYPE
################################################################################
"""
    `Component(name::String, object::Union{<:ObjectTypes, Array{Component, 1}};
optargs...)`

Defines an object placed at a location and orientation in space. Give it an
array of objects to define a component made out of multiple components.

# OPTIONAL ARGUMENTS
* `id::Int`                     : Component number identifier
* `O::Array{Real, 1}`           : Origin of object coordinate system
* `Oaxis::Array{Real, 2}`       : Orientation of coordinate sytem
* `description::String`         : Useful description
* `comments::String`            : Vent about your life here
* `vendor::String`              : Vendor information
"""
immutable Component{T1<:RType, T2<:RType}

    # User inputs
    name::String                        # Name of component
    object::Union{ObjectTypes, Array{Component, 1}}  # Mass and geometric properties

    # Optional inputs
    id::Int                             # Component number identifier
    O::Array{T1, 1}                     # Origin of object coordinate system
    Oaxis::Array{T2, 2}                 # Orientation of coordinate sytem
    description::String                 # Useful description
    comments::String                    # Vent about your life here
    vendor::String                      # Vendor information

    Component{T1,T2}(  name, object;
                id=-1,
                O=zeros(T1, 3), Oaxis=eye(T2, 3),
                description="", comments="", vendor=""
             ) where {T1,T2} = new(
                name, object,
                id,
                O, Oaxis,
                description, comments, vendor
             )
end

# Constructor that identifies parametric types automatically
Component(name, object;
          O::Array{T1, 1}=zeros(Float64, 3), Oaxis::Array{T2, 2}=eye(Float64, 3),
          optargs...) where {T1, T2} = Component{T1, T2}(
                                    name, object; O=O, Oaxis=Oaxis, optargs...)

# Base.length(cmp::Component)

##### FUNCTIONS  ###############################################################
"""
    `clone(component, O, Oaxis)`
Returns a clone of this component in the new location `O` and orientation `Oaxis`
"""
function clone(cmp::Component, O::Array{T1, 1}, Oaxis::Array{T2, 1}
                                                ) where {T1<:RType, T2<:RType}
    return Component(cmp.name, cmp.object;
                        id=cmp.id,
                        O=O, Oaxis=Oaxis,
                        description=cmp.description, comments=cmp.comments,
                        vendor=cmp.vendor)
end

"`clone(component, O)`"
clone(cmp::Component, O::Array{T, 1}) where T = clone(cmp, O, cmp.Oaxis)

"`clone(component, Oaxis)`"
clone(cmp::Component, Oaxis::Array{T, 2}) where T = clone(cmp, cmp.O, Oaxis)

"`clone(component)`"
clone(cmp::Component) = clone(cmp, cmp.O, cmp.Oaxis)
##### INTERNAL FUNCTIONS  ######################################################

##### END OF COMPONENTS ########################################################
