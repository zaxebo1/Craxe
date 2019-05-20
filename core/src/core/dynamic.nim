import core
import arrays

type
    AnonField* = ref object
        name*:string
        value*:Dynamic

    # Haxe anonimous object
    AnonObject* = seq[AnonField]

    DynamicHaxeObject* = object of HaxeObject
        getFieldByName*: proc(name:string):Dynamic
        setFieldByName*: proc(name:string, value:string):Dynamic

    DynamicHaxeObjectRef* = ref DynamicHaxeObject

    # Dynamic
    DynamicType* = enum
        TString, TInt, TFloat, TAnonObject, TClass, TPointer

    Dynamic* = ref object
        case kind*: DynamicType
        of TString: 
            fstring*:string
        of TInt: 
            fint*:int
        of TFloat: 
            ffloat*:float
        of TAnonObject: 
            fanon*: AnonObject
        of TClass: 
            fclass*: DynamicHaxeObjectRef
        of TPointer:
            fpointer*: pointer
# AnonObject
proc newAnonObject*(names: seq[string]) : AnonObject =
    result = newSeqOfCap[AnonField](names.len)
    for i in 0..<names.len:
        result[0] = AnonField(name: names[i])

proc newAnonObject*(fields: seq[AnonField]) : AnonObject =
    fields

proc setField*[T](this:AnonObject, pos:int, value:T) {.inline.} =
    this[pos].value = value

proc setField*[T](this:AnonObject, name:string, value:T) {.inline.} =
    for fld in this:
        if fld.name == name:
            fld.value = value

template getField*(this:AnonObject, pos:int):Dynamic =
    this[pos].value

proc getField*(this:AnonObject, name:string):Dynamic =
    for fld in this:
        if fld.name == name:
            return fld.value

proc getFields*(this:AnonObject):HaxeArray[string] =
    result = newHaxeArray[string]()
    for f in this:
        discard result.push(f.name)

# Dynamic 
proc `$`*(this:Dynamic):string =
    case this.kind
    of TString:
        return this.fstring
    of TInt:
        return $this.fint
    of TFloat:
        return $this.ffloat
    of TAnonObject:
        return $this[]
    else:
        return "Dynamic unknown"

template newDynamic*(value:string):Dynamic =
    Dynamic(kind:TString, fstring: value)

template newDynamic*(value:int):Dynamic =
    Dynamic(kind:TInt, fint: value)

template newDynamic*(value:float):Dynamic =
    Dynamic(kind:TFloat, ffloat: value)

template newDynamic*(value:AnonObject):Dynamic =
    Dynamic(kind:TAnonObject, fanon: value)

template newDynamic*(value:DynamicHaxeObjectRef):Dynamic =
    Dynamic(kind:TClass, fclass: value)

proc newDynamic*(value:pointer):Dynamic =
    Dynamic(kind:TPointer, fpointer: value)

proc getField*(this:Dynamic, name:string):Dynamic =
    case this.kind
    of TAnonObject:
        return getField(this.fanon, name)
    of TClass:
        return this.fclass.getFieldByName(name)
    else:
        return nil

proc getFieldNames*(this:Dynamic):HaxeArray[string] =
    case this.kind
    of TAnonObject:
        return this.fanon.getFields()
    else:
        return nil

template call*[T](this:Dynamic, tp:typedesc[T], args:varargs[untyped]):untyped =    
    case this.kind
    of TPointer:
        var pr:T = cast[tp](this.fpointer)
        pr(args)
    else:
        raise newException(ValueError, "Dynamic wrong type")

template call*[T](this:Dynamic, name:string, tp:typedesc[T], args:varargs[untyped]):untyped =    
    case this.kind:
    of TAnonObject, TClass:
        this.getField(name).call(tp, args)
    else:
        raise newException(ValueError, "Dynamic wrong type")
    

converter toInt*(this:Dynamic):int =
    case this.kind
    of TInt:
        return this.fint
    else:
        raise newException(ValueError, "Dynamic wrong type")

converter toFloat*(this:Dynamic):float =
    case this.kind
    of TFloat:
        return this.ffloat
    else:
        raise newException(ValueError, "Dynamic wrong type")
    
converter toString*(this:Dynamic):string =
    case this.kind
    of TString:
        return this.fstring
    else:
        raise newException(ValueError, "Dynamic wrong type")

converter toDynamic*[T](this: T):Dynamic =
    newDynamic(this)