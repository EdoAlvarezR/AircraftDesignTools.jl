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
  * `id::Union{Int,String}`       : Component number identifier
  * `O::Array{T1, 1}`             : Origin of object coordinate system
  * `Oaxis::Array{T2, 2}`         : Orientation of coordinate sytem
  * `description::String`         : Useful description
  * `comments::String`            : Vent about your life here
  * `vendor::String`              : Vendor information
  * `cost::Real`                  : Cost of this component

  and the following functions

```julia
    "Saves a vtk file of this component"
    save_vtk(cmp::ComponentType, file_name; path="", num=-1) = ...

    "Returns the number of items that make this component"
    Base.length(cmp::ComponentType) = ...
```
"""
abstract type AbstractComponent{T1, T2} end


##### COMMON FUNCTIONS  ########################################################
"""
    `clone(component, O, Oaxis)`
Returns a clone of this component in the new location `O` and orientation `Oaxis`
"""
function clone(cmp::CompType, O::Array{T1, 1}, Oaxis::Array{T2, 2};
                _avoid=[:name, :subcomponents, :O, :Oaxis]
                    ) where {CompType<:AbstractComponent, T1<:RType, T2<:RType}

    optargs = [(fname, getfield(cmp, fname)) for fname in fieldnames(cmp)
                                                          if !(fname in _avoid)]
    return CompType(cmp.name, cmp.subcomponents;
                        O=O, Oaxis=Oaxis,
                        optargs...)
end

"`clone(component, O)`"
clone(cmp::AbstractComponent, O::Array{T, 1}) where T = clone(cmp, O, cmp.Oaxis)

"`clone(component, Oaxis)`"
clone(cmp::AbstractComponent, Oaxis::Array{T, 2}) where T = clone(cmp, cmp.O, Oaxis)

"`clone(component)`"
clone(cmp::AbstractComponent) = clone(cmp, cmp.O, cmp.Oaxis)



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
                                        "O"             => cmp.O,
                                        "Oaxis"         => cmp.Oaxis,
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

Defines an object placed at a location and orientation in space.

**OPTIONAL ARGUMENTS**
* `id::Union{Int,String}`       : Component number identifier
* `O::Array{Real, 1}`           : Origin of object coordinate system
* `Oaxis::Array{Real, 2}`       : Orientation of coordinate sytem
* `description::String`         : Useful description
* `comments::String`            : Vent about your life here
* `vendor::String`              : Vendor information
* `cost::Real`                  : Cost of this component
"""
immutable Component{T1<:RType, T2<:RType} <: AbstractComponent{T1, T2}

    # User inputs
    name::String                        # Name of component
    subcomponents::ObjectTypes          # Mass and geometric of this component

    # Optional inputs
    id::Union{Int,String}               # Component number identifier
    O::Array{T1, 1}                     # Origin of object coordinate system
    Oaxis::Array{T2, 2}                 # Orientation of coordinate sytem
    description::String                 # Useful description
    comments::String                    # Vent about your life here
    vendor::String                      # Vendor information
    cost::RType                         # Cost of this component

    Component{T1,T2}(  name, subcomponents;
                id=-1,
                O=zeros(T1, 3), Oaxis=eye(T2, 3),
                description="", comments="", vendor="",
                cost=0
             ) where {T1,T2} = new(
                name, subcomponents,
                id,
                O, Oaxis,
                description, comments, vendor,
                cost
             )
end

# Constructor that identifies parametric types automatically
Component(name, subcomponents;
          O::Array{T1, 1}=zeros(Float64, 3), Oaxis::Array{T2, 2}=eye(Float64, 3),
          optargs...) where {T1, T2} = Component{T1, T2}(
                              name, subcomponents; O=O, Oaxis=Oaxis, optargs...)

"""
    `save_shape(cmp::Component, filename; optargs...)`

Generates a vtk file with the shape of this component.
"""
function save_shape(cmp::Component; prefix="", suffix="_shape",
                                    O=zeros(Float64, 3), Oaxis=eye(Float64, 3),
                                    optargs...)
    save_vtk(cmp.subcomponents.shape, prefix*_name(cmp)*suffix;
                O=gt.countertransform(cmp.O, Oaxis, O),
                Oaxis=cmp.Oaxis*Oaxis, optargs...)
end


"""
    `System(name::String, components::Array{AbstractComponent, 1}; optargs...) <: AbstractComponent`

Defines a system made out of components. This allows for recursive definition of
systems holding other systems as subcomponents.

**OPTIONAL ARGUMENTS**
* `id::Union{Int,String}`       : System number identifier
* `O::Array{Real, 1}`           : Origin of system coordinate system
* `Oaxis::Array{Real, 2}`       : Orientation of coordinate sytem
* `description::String`         : Useful description
* `comments::String`            : Vent about your life here
* `vendor::String`              : Vendor information
"""
immutable System{C<:AbstractComponent, T1<:RType, T2<:RType, T3<:RType,
                                        T4<:RType} <: AbstractComponent{T1, T2}

    # User inputs
    name::String                        # Name of component
    subcomponents::Array{C, 1}          # Components that make this system

    # Optional inputs
    id::Union{Int,String}               # Component number identifier
    O::Array{T1, 1}                     # Origin of coordinate system
    Oaxis::Array{T2, 2}                 # Orientation of coordinate sytem
    subO::Array{Array{T3, 1}, 1}        # Origin of subcomps coordinate systems
    subOaxis::Array{Array{T4, 2}, 1}    # Orientation of subcomps coordinate sytems
    description::String                 # Useful description
    comments::String                    # Vent about your life here
    vendor::String                      # Vendor information
    cost::RType                         # Cumulative cost of subcomponents

    System{C,T1,T2, T3, T4}(  name, subcomponents;
                id=-1,
                O=zeros(T1, 3), Oaxis=eye(T2, 3),
                subO=[zeros(T3, 3) for i in 1:length(subcomponents)],
                subOaxis=[eye(T4, 3) for i in 1:length(subcomponents)],
                description="", comments="", vendor="",
                cost=_calc_cost(subcomponents)
             ) where {C,T1,T2,T3,T4} = _checkO(subcomponents, subO, subOaxis) ?
             new(
                name, subcomponents,
                id,
                O, Oaxis,
                subO,
                subOaxis,
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
          O::Array{T1, 1}=zeros(Float64, 3), Oaxis::Array{T2, 2}=eye(Float64, 3),
          subO::Array{Array{T3, 1}, 1}=[zeros(Float64, 3) for i in 1:length(subcomponents)],
          subOaxis::Array{Array{T4, 2}, 1}=[eye(Float64, 3) for i in 1:length(subcomponents)],
          optargs...
      ) where {T1, T2, T3, T4} =
      System{eltype(subcomponents), T1, T2, T3, T4}(
                            name, subcomponents; O=O, Oaxis=Oaxis,
                                                 subO=subO, subOaxis=subOaxis,
                                                                    optargs...)

"""
    `save_shape(cmp::System, filename; optargs...)`

Generates a vtk file with the shape of all subcomponents component.
"""
function save_shape(cmp::System; prefix="", suffix="_shape",
                                 O=zeros(Float64, 3), Oaxis=eye(Float64, 3), optargs...)

    newO = gt.countertransform(cmp.O, Oaxis, O)
    newOaxis = cmp.Oaxis*Oaxis

    for (i,subcmp) in enumerate(cmp.subcomponents)
        save_shape(subcmp; prefix=prefix*_name(cmp)*"_", suffix=suffix,
                            O=gt.countertransform(cmp.subO[i], newOaxis, newO),
                            Oaxis=cmp.subOaxis[i]*newOaxis,
                            optargs...)
    end
end
##### END OF COMPONENT IMPLEMENTATIONS #########################################

# Declares implementations of AbstractComponent
const ComponentTypes = Union{Component, System}
