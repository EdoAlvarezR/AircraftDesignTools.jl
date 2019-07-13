#=##############################################################################
# DESCRIPTION
    Definition of massified objects

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
  Implementations of AbstractObject are expected to have the following fields.
  * `shape::ShapeType`      : Shape of object.
  * `density::Real`         : density of object.
  * `dunits::String`        : Units of density.

  and the following functions

```julia
    "Returns a tuple (x1, x2, x3) with the coordinates of the object center of
    gravity"
    cg(self::ObjectType) = ...

    "Return the mass of the object"
    mass(self::ObjectType) = ...

    "Returns the units of the spatial density"
    _vunits(self::ObjectType) = ...
```
"""
abstract type AbstractObject{S, R} end

##### COMMON FUNCTIONS  ########################################################
cgunits(obj::AbstractObject) = centroidunits(obj.shape)

function massunits(obj::AbstractObject)
    vunits = _vunits(obj)

    if contains(obj.dunits, "/"*vunits)
        return replace(obj.dunits, "/"*vunits, "", 1)

    elseif contains(obj.dunits, " / "*vunits)
        return replace(obj.dunits, " / "*vunits, "", 1)

    else
        return obj.dunits*vunits
    end
end
##### COMMON INTERNAL FUNCTIONS  ###############################################

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

cg(self::ObjectVol) = centroid(self.shape)
mass(self::ObjectVol) = self.density * volume(self.shape)
_vunits(self::ObjectVol) = volumeunits(self.shape)

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

cg(self::ObjectSurf) = centroid(self.shape)
mass(self::ObjectSurf) = self.density * area(self.shape)
_vunits(self::ObjectSurf) = areaunits(self.shape)
##### END OF OBJECT IMPLEMENTATIONS ############################################




# Declares implementations of AbstractObject
const ObjectTypes = Union{ObjectVol, ObjectSurf}
