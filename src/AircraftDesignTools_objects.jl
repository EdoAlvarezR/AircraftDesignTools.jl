#=##############################################################################
# DESCRIPTION
    Definition of massified objects.

# AUTHORSHIP
  * Author    : Eduardo J. Alvarez
  * Email     : Edo.AlvarezR@gmail.com
  * Created   : Jul 2019
  * License   : AGPL-3.0
=###############################################################################

################################################################################
# ABSTACT OBJECT TYPE
################################################################################
"""
  Implementations of AbstractObject are expected to have the following fields
  * `shape::ShapeType`      : Shape of object.
  * `density::Real`         : density of object.
  * `dunits::String`        : Units of density.

  and the following functions

```julia

    "Returns the mass-normalizing value (volume, area, etc)"
    _v(::Type{O}, shape::S) where {O<:ObjectPoint, S<:ShapeTypes} = ...

    "Returns the mass-normalizing units"
    _vunits(::Type{O}, shape::S) where {O<:ObjectPoint, S<:ShapeTypes} = ...
```
"""
abstract type AbstractObject{S, R} end

##### COMMON FUNCTIONS  ########################################################
"""
    `cg(object::ObjectType)`
Returns the coordinates of the center of gravity of this object.
"""
cg(obj::O) where {O<:AbstractObject} = centroid(obj.shape)

"""
    `cgunits(object::ObjectType)`
Returns the units of length of the center of gravity.
"""
cgunits(obj::O) where {O<:AbstractObject} = centroidunits(obj.shape)

"""
    `mass(object::ObjectType)`
Returns the mass of this object.
"""
mass(obj::O) where {O<:AbstractObject} = obj.density * _v(O, obj.shape)

"""
    `massunits(object::ObjectType)`
Returns the units of mass.
"""
function massunits(obj::O) where {O<:AbstractObject}
    vunits = _vunits(O, obj.shape)

    if contains(obj.dunits, "/"*vunits)
        return replace(obj.dunits, "/"*vunits, "", 1)

    elseif contains(obj.dunits, " / "*vunits)
        return replace(obj.dunits, " / "*vunits, "", 1)

    else
        return obj.dunits*vunits
    end
end
##### COMMON INTERNAL FUNCTIONS  ###############################################
Base.length(obj::AbstractObject) = 1

##### END OF ABSTRACT OBJECT ###################################################

################################################################################
# OBJECT IMPLEMENTATION TYPES
################################################################################
"""
    `ObjectVol(shape, density)`
Volumetric object with shape and mass properties assuming uniform density.
"""
immutable ObjectVol{S<:ShapeTypes, R<:RType} <: AbstractObject{S, R}
    shape::S
    density::R
    dunits::String
end
ObjectVol(shape, density) = ObjectVol(shape, density, "kg/m^3")

_v(::Type{O}, shape::S) where {O<:ObjectVol, S<:ShapeTypes} = volume(shape)
_vunits(::Type{O}, shape::S) where {O<:ObjectVol, S<:ShapeTypes} = volumeunits(shape)

"""
    `ObjectVol(shape, density)`
Surface object with shape and mass properties assuming uniform area-based
density.
"""
immutable ObjectSurf{S<:ShapeTypes, R<:RType} <: AbstractObject{S, R}
    shape::S
    density::R
    dunits::String
end
ObjectSurf(shape, density) = ObjectVol(shape, density, "kg/m^2")

_v(::Type{O}, shape::S) where {O<:ObjectSurf, S<:ShapeTypes} = area(shape)
_vunits(::Type{O}, shape::S) where {O<:ObjectSurf, S<:ShapeTypes} = areaunits(shape)


"""
    `ObjectPoint(mass)`
A volume-less point object.
"""
immutable ObjectPoint{S<:ShapeTypes, R<:RType} <: AbstractObject{S, R}
    shape::S
    density::R
    dunits::String
end
ObjectPoint(mass) = ObjectPoint(ShapePoint(), mass, "kg")

_v(::Type{O}, shape::S) where {O<:ObjectPoint, S<:ShapeTypes} = 1
_vunits(::Type{O}, shape::S) where {O<:ObjectPoint, S<:ShapeTypes} = ""
##### END OF OBJECT IMPLEMENTATIONS ############################################

# Declares implementations of AbstractObject
const ObjectTypes = Union{ObjectVol, ObjectSurf, ObjectPoint}



##### UTILITIES  ###############################################################
"""
    `object_from_mass(shape::S, mass::R; objecttype::Type{O}=ObjectVol{S, R},
massunits::String="kg") where {S<:ShapeTypes, R<:RType, O<:ObjectTypes}`

Returns an object of type `objecttype` where the density is calculated from the
given mass and shape.
"""
function object_from_mass(shape::S, mass::R; objecttype::Type{O}=ObjectVol{S, R},
                                             massunits::String="kg"
                               ) where {S<:ShapeTypes, R<:RType, O<:ObjectTypes}
    vunits = _vunits(objecttype, shape)
    dunits = length(vunits) == 0 ? massunits : massunits*"/"*vunits
    return objecttype(shape, mass/_v(objecttype, shape), dunits)
end
################################################################################
