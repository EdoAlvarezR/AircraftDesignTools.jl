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
    `AbstractComponent`

  Implementations of AbstractComponent are expected to have the following fields
  * `name::String`                : Name of this component
  * `subcomponents`               : Subcomponents that make this component
  * `id::Union{Int,String}`       : Component number identifier
  * `description::String`         : Useful description
  * `comments::String`            : Vent about your life here
  * `vendor::String`              : Vendor information
  * `cost::Real`                  : Cost of this component

  and the following functions

```julia
    "Saves a vtk file of this component and returns a string with file names"
    save_shape(cmp::ComponentType, file_name; path="", num=-1) = ...

    "Returns the number of items that make this component"
    Base.length(cmp::ComponentType) = ...
```
"""
abstract type AbstractComponent end


##### COMMON FUNCTIONS  ########################################################

"""
    `getdict(cmp::AbstractComponent; format::String="simple")`

Returns a dictionary representation of this component. Give it `format="bom"` to
obtain a bill of materials of all basic component.
"""
function getdict(cmp::AbstractComponent; format::String="recursive",
                                                    _dict=OrderedDict())

    if format in ["simple", "recursive", "bom"]

        if format=="simple" || !(typeof(cmp.subcomponents)<:AbstractArray) # Base case

            # Format subcomponents string
            subcomps = typeof(cmp.subcomponents)<:AbstractArray ? [
                                    sub.name for sub in cmp.subcomponents] : []
            subcomps_str = ""
            for (i, sub) in enumerate(subcomps)
                subcomps_str *= (i==1 ? "" : ", ")*sub
            end

            if cmp in keys(_dict)   # Add one unit
                _dict[cmp]["Units"] += 1
                _dict[cmp]["Total cost (\$)"] += _dict[cmp]["\$/unit"]

            else                    # Initialize this component
                _dict[cmp] = OrderedDict(
                                        "Name"          => cmp.name,
                                        "ID"            => cmp.id,
                                        "Subcomponents" => subcomps_str,
                                        "Description"   => cmp.description,
                                        "Comments"      => cmp.comments,
                                        "Vendor"        => cmp.vendor,
                                        "\$/unit"       => cmp.cost,
                                        "Units"         => 1,
                                        "Total cost (\$)" => cmp.cost,
                                     )

            end

            return _dict

        else                                            # Recursive case

            if format!="bom"    # Add this system as a component
                getdict(cmp; format="simple", _dict=_dict)
            end

            for this_cmp in cmp.subcomponents   # Add subcomponents
                getdict(this_cmp; format=format, _dict=_dict)
            end

            return _dict
        end

    else
        error("Invalid format \"$format\"."*
              " Try \"simple\", \"recursive\", or \"bom\".")
    end
end

"""
    `getdataframe(cmp::AbstractComponent; format::String="simple")`

Returns a DataFrame representation of this component. Give it `format="bom"` to
obtain a bill of materials of the component.
"""
function getdataframe(cmp::AbstractComponent; ignoreheader=["O", "Oaxis"],
                                                                     optargs...)
    dict = getdict(cmp; optargs...)
    header = keys(dict.vals[1])
    cmps = keys(dict)

    return DataFrames.DataFrame(;[
                                    (Symbol(h), [dict[cmp][h] for cmp in cmps])
                                        for h in header if !(h in ignoreheader)
                                 ]...)
end

"""
    `displaybom(cmp::AbstractComponent; optargs...)`

Displays the bill of materials as a table of all basic subcomponents that make
this component.
"""
function displaybom(cmp::AbstractComponent; optargs...)
    df = getdataframe(cmp; format="bom", optargs...)
    display(df)
end

##### COMMON INTERNAL FUNCTIONS  ###############################################
Base.length(cmp::AbstractComponent) = length(cmp.subcomponent)

function _calc_cost(cmps::Array{C}) where {C<:AbstractComponent}
    cost = 0.0
    for cmp in cmps
        cost += cmp.cost
    end
    return cost
end

function _name(cmp::AbstractComponent; del=[" ", "-", "_", "#", ".", ",", "",
                                            "/", "\\", "(", ")", "\t", "\n",
                                            "&", "\$", "@", "*", "<", ">", ":",
                                            ";", "~"])
    name = cmp.name
    for str in del
        name = replace(name, str, "")
    end
    return name
end

"""
    show(io::IO, mime::MIME, cmp::AbstractComponent)
Render a component to an I/O stream in MIME type `mime`.
"""
Base.show(io::IO, mime::MIME, cmp::AbstractComponent)
Base.show(io::IO, mime::MIME"text/html", cmp::AbstractComponent; optargs...) =
    _show(io, mime, cmp; optargs...)
Base.show(io::IO, mime::MIME"text/latex", cmp::AbstractComponent; optargs...) =
    _show(io, mime, cmp; optargs...)
Base.show(io::IO, mime::MIME"text/csv", cmp::AbstractComponent; optargs...) =
    _show(io, mime, cmp; optargs...)
Base.show(io::IO, mime::MIME"text/tab-separated-values", cmp::AbstractComponent; optargs...) =
    _show(io, mime, cmp; optargs...)
Base.show(io::IO, mime::MIME"text/plain", cmp::AbstractComponent; optargs...) =
    _show(io, mime, cmp; optargs...)
Base.show(io::IO, cmp::AbstractComponent; optargs...) =
    _show(io, mime, cmp; optargs...)
Base.show(cmp::AbstractComponent; optargs...) =
    _show(io, mime, cmp; optargs...)

_show(io, mime, cmp::AbstractComponent; optargs...) = (
                        df = getdataframe(cmp); show(io, mime, df; optargs...));
##### END OF ABSTRACT COMPONENT ################################################


################################################################################
# COMPONENT IMPLEMENTATION TYPES
################################################################################
"""
    `Component(name::String, object::ObjectTypes; optargs...) <: AbstractComponent`

Defines an object with the location and orientation given by the shape
definition of `object`.

**OPTIONAL ARGUMENTS**
* `id::Union{Int,String}`       : Component number identifier
* `description::String`         : Useful description
* `comments::String`            : Vent about your life here
* `vendor::String`              : Vendor information
* `cost::Real`                  : Cost of this component
"""
immutable Component <: AbstractComponent

    # User inputs
    name::String                        # Name of component
    subcomponents::ObjectTypes          # Mass and geometric of this component

    # Optional inputs
    id::Union{Int,String}               # Component number identifier
    description::String                 # Useful description
    comments::String                    # Vent about your life here
    vendor::String                      # Vendor information
    cost::RType                         # Cost of this component

    Component(  name, subcomponents;
                id=-1,
                description="", comments="", vendor="",
                cost=0
             ) = new(
                name, subcomponents,
                id,
                description, comments, vendor,
                cost
             )
end


"""
    `save_shape(cmp::Component, filename; O=zeros(3), Oaxis=eye(3), optargs...)`

Generates a vtk file with the shape of this component at origin `O` and
orientation `Oaxis`. Returns a string with the name of the vtk file.
"""
save_shape(cmp::Component; prefix="", suffix="_shape", optargs...) =
    save_vtk(cmp.subcomponents.shape, prefix*_name(cmp)*suffix; optargs...)

# ------------------------------------------------------------------------------
"""
    `System(name::String, components::Array{AbstractComponent, 1}; optargs...) <: AbstractComponent`

Defines a system made out of components. This allows for recursive definition of
systems holding other systems as subcomponents.

**OPTIONAL ARGUMENTS**
* `id::Union{Int,String}`       : System number identifier
* `subO::Array{Array{T1, 1}, 1}`     : Origin of subcomps coordinate systems
* `subOaxis::Array{Array{T2, 2}, 1}` : Orientation of subcomps coordinate sytems
* `description::String`         : Useful description
* `comments::String`            : Vent about your life here
* `vendor::String`              : Vendor information

NOTE: `subO[i]` contains the origin of the i-th subcomponent in the coordinate
system of the system. `subOaxis[i]` contains the orientation of the i-th
subcomponent in the coordinate system of the system, with `subOaxis[i][j, :]`
the direction of the j-th unitary vector. For example, a cylinder shape
originally has centerline aligned with the z-axis with its lower face centered
at the origin. If we wanted to center it half way its length and align its
centerline with the x-axis we would give it `O = [-h/2, 0, 0]` and
`Oaxis = [0 1 0; 0 0 1; 1 0 0]`

SEE ROTOR POD EXAMPLE IN DOCUMENTATION.
"""
immutable System{C<:AbstractComponent, T1<:RType, T2<:RType} <: AbstractComponent

    # User inputs
    name::String                        # Name of component
    subcomponents::Array{C, 1}          # Components that make this system

    # Optional inputs
    id::Union{Int,String}               # Component number identifier
    subOaxis::Array{Array{T1, 2}, 1}    # Orientation of subcomps coordinate sytems
    subO::Array{Array{T2, 1}, 1}        # Origin of subcomps coordinate systems
    description::String                 # Useful description
    comments::String                    # Vent about your life here
    vendor::String                      # Vendor information
    cost::RType                         # Cumulative cost of subcomponents

    System{C,T1,T2}(  name, subcomponents;
                id=-1,
                subOaxis=[eye(T1, 3) for i in 1:length(subcomponents)],
                subO=[zeros(T2, 3) for i in 1:length(subcomponents)],
                description="", comments="", vendor="",
                cost=_calc_cost(subcomponents)
             ) where {C,T1,T2} = _checkO(subcomponents, subO, subOaxis) ?
             new(
                name, subcomponents,
                id,
                subOaxis,
                subO,
                description, comments, vendor,
                cost
             ) : nothing
end

function _checkO(subcomps, subO, subOaxis)
    if length(subO)!=length(subcomps)
        error("Invalid subcomponent origins."*
              " Expected $(length(subcomps)), got $(length(subO)).")
    elseif length(subOaxis)!=length(subcomps)
        error("Invalid subcomponent axes."*
              " Expected $(length(subcomps)), got $(length(subOaxis)).")
    end

    return true
end

# Constructor that identifies parametric types automatically
System(name, subcomponents;
          subOaxis::Array{Array{T1, 2}, 1}=[eye(Float64, 3) for i in 1:length(subcomponents)],
          subO::Array{Array{T2, 1}, 1}=[zeros(Float64, 3) for i in 1:length(subcomponents)],
          optargs...
      ) where {T1, T2} =
      System{eltype(subcomponents), T1, T2}(
                            name, subcomponents; subOaxis=subOaxis, subO=subO,
                                                                    optargs...)

"""
    `save_shape(cmp::System, filename; optargs...)`

Generates vtk files of every subcomponent, with origin `O` and orientation
`Oaxis`. Returns a string with the names of all vtk files.
"""
function save_shape(cmp::System; prefix="", suffix="_shape",
                                 Oaxis=eye(Float64, 3), O=zeros(Float64, 3),
                                 optargs...)

    str = ""
    for (i,subcmp) in enumerate(cmp.subcomponents)
        fname = save_shape(subcmp; prefix=prefix*_name(cmp)*"_$(i)", suffix=suffix,
                            Oaxis=cmp.subOaxis[i]*Oaxis,
                            O=gt.countertransform(cmp.subO[i], Oaxis', O),
                            optargs...)
        str *= fname*";"
    end
    return str
end
##### END OF COMPONENT IMPLEMENTATIONS #########################################

# Declares implementations of AbstractComponent
const ComponentTypes = Union{Component, System}
