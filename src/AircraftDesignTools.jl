"""
  Tools for sizing, layout, and optimization of aircraft design.

  # AUTHORSHIP
    * Author    : Eduardo J. Alvarez
    * Email     : Edo.AlvarezR@gmail.com
    * Created   : Jul 2019
    * License   : AGPL-3.0
"""
module AircraftDesignTools

        # Shapes
export  ShapeCuboid, ShapeCyl, ShapeSphere, ShapePoint,
        volume, area, centroid,
        volumeunits, areaunits, centroidunits,
        # Objects
        ObjectVol, ObjectSurf, ObjectPoint,
        cg, mass, cgunits, massunits,
        object_from_mass,
        # Components
        Component, System, clone,
        displaybom


# ------------ GENERIC MODULES -------------------------------------------------
import ForwardDiff
import DataFrames
import DataStructures.OrderedDict

# ------------ FLOW LAB MODULES ------------------------------------------------

# GeometricTools from https://github.com/byuflowlab/GeometricTools.jl
import GeometricTools
const gt = GeometricTools


# ------------ GLOBAL VARIABLES AND DATA STRUCTURES ----------------------------
const module_path = splitdir(@__FILE__)[1]      # Path to this module

const RType = Union{Float64,                    # Concrete real types
                    Int64,
                    ForwardDiff.Dual{Void,Float64,3},
                    ForwardDiff.Dual{Void,Int64,3}
                    }

# ------------ HEADERS ---------------------------------------------------------
for header_name in ["shapes", "objects", "components"]
  include("AircraftDesignTools_"*header_name*".jl")
end


end # END OF MODULE
