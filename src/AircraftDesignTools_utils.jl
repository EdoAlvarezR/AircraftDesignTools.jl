#=##############################################################################
# DESCRIPTION
    Utilities.

# AUTHORSHIP
  * Author    : Eduardo J. Alvarez
  * Email     : Edo.AlvarezR@gmail.com
  * Created   : Ago 2019
  * License   : AGPL-3.0
=###############################################################################

"""
  `rotation_matrix(roll::Real, pitch::Real, yaw::Real)`

Receives yaw, pitch, and roll angles (in degrees) and returns the rotation
matrix corresponding to this rotation.
(see http://planning.cs.uiuc.edu/node102.html)

NOTE: Naming follows aircraft convention, with
* roll:   rotation about x-axis.
* pitch:  rotation about y-axis.
* yaw:    rotation about z-axis.

**Examples**
```jldoctest
julia> M = gt.rotation_matrix(90, 0, 0)
3×3 Array{Float64,2}:
  1.0  0.0   0.0
  0.0  0.0  -1.0
  0.0  1.0   0.0

julia> X = [0, 1, 0];
julia> Xp = M*X
3-element Array{Float64,1}:
  0.0
  0.0
  1.0

julia> M = gt.rotation_matrix(0, 45, 45)
3×3 Array{Float64,2}:
  0.5    -0.707  0.5
  0.5     0.707  0.5
 -0.707   0.0    0.707

julia> X = [1, 0, 0];
julia> Xp = M*X
3-element Array{Float64,1}:
  0.5
  0.5
 -0.707
```
"""
rotation_matrix(roll, pitch, yaw) = gt.rotation_matrix2(roll, pitch, yaw)
