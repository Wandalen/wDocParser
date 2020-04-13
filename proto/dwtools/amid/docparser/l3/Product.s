( function _Product_s_() {

'use strict';

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wProduct( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Product';

// --
// routines
// --

function init( o )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.workpiece.initFields( self );

  if( o )
  self.copy( o );
}

//

function finit()
{
  return _.Copyable.prototype.finit.apply( this, arguments );
}

//

function form()
{
  let self = this;
  _.assert( arguments.length === 0 );

  self.byType.namespace = [];
  self.byType.module = [];
  self.byType.class = [];
}

//

function addEntity( entity )
{
  let self = this;
  _.assert( entity instanceof _.docgen.EntityJsdoc );

  self.entities.push( entity );

  let type = entity.typeGet();
  if( self.byType[ type ] )
  self.byType[ type ].push( entity );
  
  if( entity.orphanIs() )
  {
    self.orphans.push( entity );
  }
  else if( type !== 'module' )
  { 
    if( type === 'namespace' )
    addToByParent( entity, entity.tags.module )
    else if( type === 'class' )
    addToByParent( entity, entity.tags.module )
    else if( entity.tags.class ) 
    addToByParent( entity, entity.tags.class )
    else if( entity.tags.namespace ) 
    addToByParent( entity, entity.tags.namespace )
    else if( entity.tags.module ) 
    addToByParent( entity, entity.tags.module )
  }
  
  /* */
  
  function addToByParent( entity, parentTag )
  { 
    let parentName = removePrefix( parentTag.name );
    self.byParent[ parentName ] = self.byParent[ parentName ] || [];
    self.byParent[ parentName ].push( entity )
  }
  
  function removePrefix( src )
  {
    let firstIsSmall = /[a-z]/.test( src[ 0 ] );
    let secondIsCapital = /[A-Z]/.test( src[ 1 ] );

    if( firstIsSmall && secondIsCapital )
    return src.slice( 1 );
    return src;
  }
}
  
// --
// relations
// --

let Composes =
{
  entities : _.define.own([]),
  byType : _.define.own({}),
  byParent : _.define.own({}),
  orphans : _.define.own([]),
}

let Associates =
{
}

let Restricts =
{
}

let Medials =
{
}

let Statics =
{
}

let Events =
{
}

let Forbids =
{
}

// --
// declare
// --

let Extend =
{

  init,
  finit,

  form,

  addEntity,

  // relations

  Composes,
  Associates,
  Restricts,
  Medials,
  Statics,
  Events,
  Forbids,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

_.docgen[ Self.shortName ] = Self;

})();