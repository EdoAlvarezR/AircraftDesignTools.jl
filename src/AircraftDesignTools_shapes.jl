#=##############################################################################
# DESCRIPTION
    Definition of shapes (basic data structure).

# AUTHORSHIP
  * Author    : Eduardo J. Alvarez
  * Email     : Edo.AlvarezR@gmail.com
  * Created   : Jul 2019
  * License   : AGPL-3.0
=###############################################################################

################################################################################
# ABSTACT SHAPE TYPE
################################################################################
"""
  Implementations of AbstractShape are expected to have the following fields
  * `units::String `     : Units of the length dimensions.

  and the following functions

```julia
    "Returns the volume of this shape"
    volume(self::ShapeType) = ...

    "Returns the surface area of this shape"
    area(self::ShapeType) = ...

    "Returns a tuple (x1, x2, x3) with the coordinates of the shape centroid"
    centroid(self::ShapeType) = ...

    "Generates a vtk file with this shape and returns the name of the vtk file"
    save_vtk(self::ShapeType, filename; optargs...) = ...
```
"""
abstract type AbstractShape{T} end


##### COMMON FUNCTIONS  ########################################################
volumeunits(shape::AbstractShape) = shape.units*"^3"
areaunits(shape::AbstractShape) = shape.units*"^2"
centroidunits(shape::AbstractShape) = shape.units
##### COMMON INTERNAL FUNCTIONS  ###############################################

##### END OF ABSTRACT SHAPE ####################################################







################################################################################
# SHAPE IMPLEMENTATION TYPES
################################################################################
"""
    `ShapeCuboid(x1::Real, x2::Real, x3::Real, units::String)`
Cuboid shape formed by six parallelograms (3D rectangle)
"""
struct ShapeCuboid{T<:Real} <: AbstractShape{T}
    x1::T
    x2::T
    x3::T
    units::String
end
ShapeCuboid(x1,x2,x3) = ShapeCuboid(x1,x2,x3,"m")

volume(self::ShapeCuboid) = self.x1*self.x2*self.x3
area(self::ShapeCuboid) = 2*(self.x1*self.x2 + self.x2*self.x3 + self.x3*self.x1)
centroid(self::ShapeCuboid) = (self.x1/2, self.x2/2, self.x3/2)

function save_vtk(self::ShapeCuboid, filename; optargs...)
    gt.generate_vtk_cuboid(filename, self.x1, self.x2, self.x3;
                                                optargs...)
    return filename*".vtk"
end
# ------------------------------------------------------------------------------

"""
    `ShapeCyl(r::Real, h::Real, units::String)`
Cylindrical shape
"""
struct ShapeCyl{T<:Real} <: AbstractShape{T}
    r::T
    h::T
    units::String
end
ShapeCyl(r,h) = ShapeCyl(r,h,"m")

volume(self::ShapeCyl) = pi*self.r^2*self.h
area(self::ShapeCyl) = 2*(pi*self.r^2) + 2*pi*self.r*self.h
"Cylinder: axis goes in the direction of x3, circular section lays on x1 and x2"
centroid(self::ShapeCyl{T}) where {T} = (zero(T), zero(T), self.h/2)

function save_vtk(self::ShapeCyl, filename; optargs...)
    gt.generate_vtk_cyl(filename, self.r, self.h; optargs...)
    return filename*".vtk"
end
# ------------------------------------------------------------------------------

"""
    `ShapeSphere(r::Real, units::String)`
Spherical shape
"""
struct ShapeSphere{T<:Real} <: AbstractShape{T}
    r::T
    units::String
end
ShapeSphere(r) = ShapeSphere(r,"m")

volume(self::ShapeSphere) = 4/3*pi*self.r^3
area(self::ShapeSphere) = 4*pi*self.r^2
centroid(self::ShapeSphere{T}) where {T} = (zero(T), zero(T), zero(T))

function save_vtk(self::ShapeSphere, filename; optargs...)
    gt.generate_vtk_sph(filename, self.r; optargs...)
    return filename*".vtk"
end
# ------------------------------------------------------------------------------

"""
    `ShapePoint(units::String)`
A volume-less point
"""
struct ShapePoint{T<:Real} <: AbstractShape{T}
    units::String
end
ShapePoint() = ShapePoint{Float64}("")
volume(self::ShapePoint{T}) where {T} = zero(T)
area(self::ShapePoint{T}) where {T} = zero(T)
centroid(self::ShapePoint{T}) where {T} = (zero(T), zero(T), zero(T))

function save_vtk(self::ShapePoint, filename; optargs...)
    gt.generate_vtk_point(filename, self.r; optargs...)
    return filename*".vtk"
end
# ------------------------------------------------------------------------------

"""
    `ShapeSurfGrid(grid::gt.GridTriangleSurface, units::String)`
Arbitrary shape created as a surface grid of triangular cells through
`GeometricTools` package.
"""
struct ShapeSurfGrid{T} <: AbstractShape{T}
    grid::gt.GridTriangleSurface
    units::String
end
ShapeSurfGrid(grid::gt.GridTriangleSurface, units::String) = ShapeSurfGrid{Float64}(grid, units)
ShapeSurfGrid(grid::gt.GridTriangleSurface) = ShapeSurfGrid{Float64}(grid, "m")

volume(self::ShapeSurfGrid) = gt.get_volume(self.grid)
area(self::ShapeSurfGrid) = gt.get_area(self.grid)
centroid(self::ShapeSurfGrid) = gt.get_centroid(self.grid)

function save_vtk(self::ShapeSurfGrid, filename; optargs...)
    gt.save(self.grid, filename; optargs...)
    return filename*".vtk"
end
##### END OF SHAPE IMPLEMENTATIONS #############################################

# Declares implementations of AbstractShape
const ShapeTypes = Union{ShapeCuboid, ShapeCyl, ShapeSphere, ShapePoint,
                                                                  ShapeSurfGrid}
