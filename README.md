#  EUSTACE 

## A simple IoC container swift implementation


### Abstract

DI              dependency injection

DIP            dependency inversion principle

IoC             inversion of control

IoC container

Abstract Factory design pattern

Service locator design pattern

Creational design pattern


Take the above notions, take a few verbs such as 'implement' 'control' 'achieve' 'apply' 'is based on' ...,  and mix them up to build a random sentence.
Whatever sentence you get, you'll be able to find someone out there who is teaching it as the truth.

I am no different and I want to propose my bit:

Through `DI` you can achieve `DIP`

`IoC container` implements `service locator design pattern`

`IoC container` also implements `creational design pattern`

Through `IoC container` you achieve `DI`  thus `DIP`

`Abstract Factory`  belongs to `creational design pattern` family 

Through `Abstract Factory` you can also achieve `DI`  thus `DIP` 

An `IoC container` along with `Abstract Factory`, is one of the known standard solutions to implement automatic dependency injection.

Just as factories, containers are centralised objects which are able to create new instances of all other types, resolving at runtime the abstract dependencies into concrete types.

Ok, enough theory.

`IoC Container` is an hash table (at least this one is).

###  Basic container principles

Any IoC container is based on three main actions:

- register
- resolve
- dispose

The underlying data structure is a hash table where the key is the abstract type (typically a protocol) we want to resolve, and the value is how to resolve it, namely, a creator block.

Quite clearly, the three actions above turn out to be storing, fetching, and deleting entries in the hash table.

###  A few notes about circular dependencies

Circular dependencies among objects or types in general are a known issue which should be avoided. An IoC container or a factory or any other tool cannot always solve the issue if the code which uses them has generated it by design.

Is is still container's user code responsibility to break circular dependencies with a weak reference, for instance

If two classes hold mutual non-optional references, they are not instantiable and a container can't change this.

Still, in some cases some help can be provided.

This IoC container is able to detect circular dependencies within its resolve function, verifying that a given service type has not been resolved before.

### How to use it in your project

#### Using Carthage

github "f-max/Eustace" 

#### Using SPM

In 'Package Dependencies' section add it by using url 'https://github.com/f-max/Eustace'

