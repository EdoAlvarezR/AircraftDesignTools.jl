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
"""
rotation_matrix(roll, pitch, yaw) = gt.rotation_matrix2(-roll, -pitch, -yaw)
