{.experimental: "codeReordering".}

import tables

type
    # Objects that can calculate self hash
    Hashable = concept x
       x.hash is proc():int

    # Main object for all haxe objects
    # All classes without reflection
    HaxeObject* = RootObj

    # Reference to HaxeObject
    HaxeObjectRef* = ref HaxeObject

    # Interface object
    # Container for HaxeObject with links for it fields
    InterfaceHaxeObject* = object of HaxeObject
        obj*: HaxeObjectRef

    # Reference to InterfaceHaxeObject
    InterfaceHaxeObjectRef* = ref InterfaceHaxeObject

    # Object with introspection but no possibility to add/remove fields
    # Classes with reflection, or using as dynamic
    IntrospectiveHaxeObject* = object of HaxeObject
        # Return names of object fields
        getFields*:proc():HaxeArray[string]
        # Return field value as Dynamic by name
        getFieldByName*:proc(name:string):Dynamic
        # Set field value by name
        setFieldByName*:proc(name:string, value:Dynamic):void

    # Reference to IntrospectiveHaxeObject    
    IntrospectiveHaxeObjectRef* = object of IntrospectiveHaxeObject

    # Mutable object with all reflection possibility
    # Anonimous object (typedef)
    ReflectiveHaxeObject* = object of IntrospectiveHaxeObject
        # Fields for add/delete by reflection
        fields: HaxeArray[DynamicField]

    ReflectiveHaxeObjectRef* = ref ReflectiveHaxeObject

    # Value object
    Struct* = object of HaxeObject

    ValueType* = int | string | float | object

    Null*[ValueType] = object
        case has*:bool
        of true:
            value*:ValueType
        of false:
            discard

    # --- Haxe Iterator ---

    HaxeIterator*[T] = ref object of InterfaceHaxeObject
        hasNext*:proc():bool
        next*:proc():T

    # --- Haxe Array ---    

    HaxeArrayIterator*[T] = ref object of HaxeIterator[T]
        arr:HaxeArray[T]
        currentPos:int

    HaxeArray*[T] = ref object of HaxeObject
        data*:seq[T]

    # --- Haxe Map

    # Base map
    HaxeMap*[K, V] = ref object of HaxeObject
        data*:Table[K, V]

    # Haxe String map
    HaxeStringMap*[T] = HaxeMap[string, T]

    # Haxe Int map
    HaxeIntMap*[T] = HaxeMap[int, T]

    # Haxe object map
    HaxeObjectMap*[K, V] = HaxeMap[K, V]

    # --- Dynamic ---
    
    # Field of dynamic object
    DynamicField* = ref object
        name*:string
        case isLink:bool
        of true:
            getProc*:proc():Dynamic
            setProc*:proc(v:Dynamic):void
        else:
            value*:Dynamic    

    # Dynamic
    DynamicType* = enum
        TString, TInt, TFloat, TObject, TProc

    Dynamic* = ref object of HaxeObject
        case kind*: DynamicType
        of TString: 
            fstring*:string
        of TInt: 
            fint*:int
        of TFloat: 
            ffloat*:float
        of TObject:
            fobject*: IntrospectiveHaxeObjectRef
        of TProc:
            fproc*: pointer

    # --- Haxe Enum ---

    # Haxe enum
    HaxeEnum* = ref object of HaxeObject
        index*:int

template toDynamic*(this:untyped):untyped =
    newDynamic(this)

template newDynamic*(value:string):Dynamic =
    Dynamic(kind:TString, fstring: value)

template newDynamic*(value:int):Dynamic =
    Dynamic(kind:TInt, fint: value)

template newDynamic*(value:float):Dynamic =
    Dynamic(kind:TFloat, ffloat: value)

template newDynamic*(value:ReflectiveHaxeObjectRef):Dynamic =
    Dynamic(kind:TObject, fobject: value)

proc newDynamic*(value:proc):Dynamic =
    Dynamic(kind:TProc, fproc: cast[pointer](value))

# Core procedures
# a++
proc apOperator*[T](val:var T):T {.discardable, inline.} =        
    result = val
    inc(val)

# ++a
proc bpOperator*[T](val:var T):T {.discardable, inline.} =        
    inc(val)
    result = val

template `+`*(s:string, i:untyped): string =
    s & $i

template `+`*(i:untyped, s:string): string =
    $i & s

template `+`*(s1:string, s2:string): string =
    s1 & s2

template toString*(this:untyped):string =
    $this

# String
template length*(this:string) : int =
    len(this)

# String
template charAt*(this:string, pos:int) : string =
    $this[pos]

proc `==`*(v1:Null[ValueType], v2:ValueType):bool =
    if v1.has:
        return v1.value == v2
    return false

proc `$`*(this:Null[ValueType]):string =
    if this.has:
        return $this.value
    return "nil"

proc `==`*(v1:Hashable, v2:Hashable):bool =
    v1.hash() == v2.hash()

template hash*(this:HaxeObjectRef):int =
    cast[int](this)

proc `==`*(v1:HaxeObjectRef, v2:HaxeObjectRef):bool =
    v1.hash() == v2.hash()

proc `==`*[T](v1:Null[T], v2:Null[T]):bool =
    if v1.has and v2.has:
        return v1.value == v2.value    
    return false

# Scoped block
template valueBlock*(body : untyped) : untyped = 
    (proc() : auto {.gcsafe.} = 
        body
    )()

# --- Haxe Array ---

# HaxeArray
proc newHaxeArray*[T]() : HaxeArray[T] =
    result = HaxeArray[T]()

proc newHaxeArray*[T](data:seq[T]) : HaxeArray[T] =
    result = HaxeArray[T](data: data)

proc `[]`*[T](this:HaxeArray[T], pos:int):T =
    this.data[pos]

template push*[T](this:HaxeArray[T], value:T):int =
    this.data.add(value)
    len(this.data)

template pop*[T](this:HaxeArray[T]): T =
    let last = this.data.len - 1
    let res = this.data[last]
    delete(this.data, last)
    res

template get*[T](this:HaxeArray[T], pos:int): T =
    this.data[pos]

template length*[T](this:HaxeArray[T]): int =    
    this.data.len

template `$`*[T](this:HaxeArray[T]) : string =
    $this.data

proc newHaxeArrayIterator*[T](arr:HaxeArray[T]) : HaxeArrayIterator[T] =
    var res = HaxeArrayIterator[T](arr: arr)
    res.hasNext = proc():bool =
        return res.currentPos < length(res.arr)
    res.next = proc():T =
        result = res.arr[res.currentPos]
        inc(res.currentPos)

    return res

proc `iterator`*[T](this:HaxeArray[T]):HaxeIterator[T] =
    return newHaxeArrayIterator(this)

# --- Haxe Map --- 

const TABLE_INIT_SIZE = 64

# Haxe Map
template set*[K, V](this:HaxeMap[K, V], key:K, value:V) =
    this.data[key] = value

proc get*[K](this:HaxeMap[K, ValueType], key:K):Null[ValueType] =    
    if this.data.hasKey(key):
        return Null[ValueType](has: true, value: this.data[key])
    else:
        return Null[ValueType](has: false)

template get*[K, V](this:HaxeMap[K, V], key:K):V =
    if this.data.hasKey(key):
        this.data[key]
    else:
        nil

template `$`*[K, V](this:HaxeMap[K, V]) : string =
    $this.data

proc newStringMap*[T]() : HaxeStringMap[T] =
    result = HaxeStringMap[T]()
    result.data = initTable[string, T](TABLE_INIT_SIZE)

proc newIntMap*[T]() : HaxeIntMap[T] =
    result = HaxeIntMap[T]()
    result.data = initTable[int, T](TABLE_INIT_SIZE)

proc newObjectMap*[K, V]() : HaxeObjectMap[K, V] =
    result = HaxeObjectMap[K, V]()
    result.data = initTable[K, V](TABLE_INIT_SIZE)

# --- Dynamic ---

# ReflectiveHaxeObjectRef

proc initReflectiveObject*(this:ReflectiveHaxeObjectRef) =    
    this.fields = newHaxeArray[DynamicField]()    

proc newReflectiveObject*() : ReflectiveHaxeObjectRef =
    var res = ReflectiveHaxeObjectRef()
    initReflectiveObject(res)
    return res

proc addFieldLink*(this:ReflectiveHaxeObjectRef, name:string, getProc:proc():Dynamic, setProc:proc(v:Dynamic):void):void =
    discard this.fields.push(DynamicField(
        name: name,
        isLink: true,
        getProc: getProc,
        setProc: setProc
    ))

proc setFieldByName*(this:ReflectiveHaxeObjectRef, name:string, value:Dynamic) {.inline.} =    
    for fld in this.fields.data:
        if fld.name == name:
            if fld.isLink:
                fld.setProc(value)                
            else:
                fld.value = value
            return
    
    discard this.fields.push(DynamicField(name: name, isLink:false, value: value))

proc getFieldByName*(this:ReflectiveHaxeObjectRef, name:string):Dynamic =
    if this.fields.length < 1:
        return nil

    for fld in this.fields.data:
        if fld.name == name:
            if fld.isLink:
                return fld.getProc()
            else:
                return fld.value

    return nil

proc getFields*(this:ReflectiveHaxeObjectRef):HaxeArray[DynamicField] =
    return this.fields

# Dynamic 

proc `$`*(this:Dynamic):string =
    case this.kind
    of TString:
        return this.fstring
    of TInt:
        return $this.fint
    of TFloat:
        return $this.ffloat
    of TObject:
        let fields = this.fobject.getFields()
        var data = newSeq[string]()
        for fld in fields.data:
            data.add(fld.name & ": " & $this.fobject.getFieldByName(fld.name))
        return $data
    of TProc:
        return "Proc"

proc `$`*(this:DynamicField):string =
    if this.isLink:
        return $this.getProc()
    else:
        return $this.value

proc getField*(this:Dynamic, name:string):Dynamic {.gcsafe.} =
    case this.kind    
    of TObject:
        this.fobject.getFieldByName(name)
    else:
        nil

proc getFields*(this:Dynamic):HaxeArray[DynamicField] {.gcsafe.} =    
    case this.kind
    of TObject:
        this.fobject.getFields()
    else:
        nil

template call*[T](this:Dynamic, tp:typedesc[T]):untyped =
    case this.kind
    of TProc:
        var pr:T = cast[tp](this.fproc)
        pr()
    else:
        raise newException(ValueError, "Dynamic wrong type")

template call*[T](this:Dynamic, tp:typedesc[T], args:untyped):untyped =
    case this.kind
    of TProc:
        var pr:T = cast[tp](this.fproc)
        pr(args)
    else:
        raise newException(ValueError, "Dynamic wrong type")

template call*[T](this:Dynamic, name:string, tp:typedesc[T], args:untyped):untyped =    
    case this.kind:
    of TAnonObject, TObject:
        this.getField(name).call(tp, args)
    else:
        raise newException(ValueError, "Dynamic wrong type")

proc fromDynamic*[T](this:Dynamic, t:typedesc[T]) : T =
    case this.kind
        of TInt:
            cast[T](this.fint)
        of TString:
            cast[T](this.fstring)
        of TFloat:
            cast[T](this.ffloat)
        of TObject:
            cast[T](this.fobject)
        of TProc:
            cast[T](this.fproc)

# --- Haxe Enum ---

# Enum
proc `$`*(this:HaxeEnum) : string =
    result = $this[]

proc `==`*(e1:HaxeEnum, e2:int) : bool {.inline.} =
    result = e1.index == e2