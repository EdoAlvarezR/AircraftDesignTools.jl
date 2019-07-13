"""
  Tools for sizing, layout, and optimization of aircraft design.

  # AUTHORSHIP
    * Author    : Eduardo J. Alvarez
    * Email     : Edo.AlvarezR@gmail.com
    * Created   : Jul 2019
    * License   : AGPL-3.0
"""
module AircraftDesignTools

# ------------ GENERIC MODULES -------------------------------------------------

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
for header_name in []
  include("AircraftDesignTools_"*header_name*".jl")
end


end # END OF MODULE
