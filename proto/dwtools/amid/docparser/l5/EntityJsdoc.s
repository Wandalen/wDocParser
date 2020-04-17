( function _EntityJsdoc_s_() {

'use strict';

//

let _ = _global_.wTools;
let Parent = _.docgen.Entity;
let Self = function wEntityJsdoc( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'EntityJsdoc';

// --
// routines
// --

function _form()
{
  let self = this;
  _.assert( arguments.length === 0 );

  if( self.formed )
  return;

  self.formed = 1;
  
  return self;
}

//

function _typeGet()
{
  let self = this;
  
  if( self.tags.typedef )
  return 'typedef'
  
  if( self.tags.callback )
  return 'callback'
  
  if( self.tags.constructor )
  return 'constructor';

  if( self.tags.function || self.tags.method || self.tags.callback || self.tags.routine )
  return 'function';

  if( self.tags.class )
  return 'class';

  if( self.tags.namespace )
  return 'namespace';

  if( self.tags.module )
  return 'module';

  return 'entity';
}

//

function _orphanIs()
{
  let self = this;

  let type = self.typeGet();

  if( type === 'module' )
  return false;

  if( type === 'namespace' && !self.tags.module )
  return true;

  if( type === 'class' && !self.tags.module )
  return true;

  if( !self.tags.module && !self.tags.namespace && !self.tags.class )
  return true;

  return false;
}

//

function _templateDataMake()
{
  let self = this;
  let type = self.typeGet();
  
  _.assert( _.objectIs( self.templateData ) );
  
  let td = self.templateData;
  let tags = self.tags;
  
  let description = self.structure.description;
  
  if( description )
  {
    description = _.strLinesStrip( description );
    // let lines = _.strLinesSplit( description );
    // td.summary = lines.shift();
    // td.description = lines.join('\n');
    td.description = description;
  }
  if( tags.summary )
  { 
    // td.summary = td.summary ? td.summary + '\n' : '';
    td.summary = tags.summary.description; 
  }
  if( tags.description )
  {
    td.description = td.description ? td.description + '\n' : '';
    td.description += tags.description.description; 
  }
  
  if( tags[ type ] )
  td.name = tags[ type ].name || tags[ type ].description; //callback tags stores it name in description
  td.kind = type;
  
  if( type === 'module' )
  {
    td.module = unprefix( tags.module.name );
  }
  else if( type === 'namespace' )
  {
    td.namespace = unprefix( tags.namespace.name );
    if( tags.module )
    td.module = unprefix( tags.module.name );
  }
  else if( type === 'class' )
  { 
    td.class = unprefix( tags.class.name );
    if( tags.namespace )
    td.namespace = unprefix( tags.namespace.name );
    if( tags.module )
    td.module = unprefix( tags.module.name );
    
    if( tags.classdesc )
    {
      td.description = td.description ? td.description + '\n' : '';
      td.description += tags.classdesc.description; 
    }
  }
  else if( type === 'typedef' )
  {
    td.name = tags.typedef.name
    paramTypeMake( td, tags.typedef )
    
    if( tags.property )
    td.properties = _.arrayAs( tags.property ).map( ( e ) => 
    { 
      let property = 
      { 
        name : e.name, 
        description : e.description, 
        optional : false
      } 
      
      if( e.default )
      property.default = e.default;
      
      paramTypeMake( property, e )
      
      return property;
    })
  }
  else
  { 
    
    if( tags.method )
    {
      td.name = tags.method.name;
      td.kind = 'method'
    }
    else if( tags.routine )
    { 
      td.name = tags.routine.description;
      td.kind = 'static routine'
    }
    else if( tags.class && tags.function && !tags.static )
    {
      td.kind = 'method'
    }
    
    if( type === 'function' )
    if( tags.static || !tags.class && tags.namespace )
    td.kind = 'static routine';
    
    //
    
    if( tags.param )
    td.params = _.arrayAs( tags.param ).map( ( e ) => 
    { 
      let param = 
      { 
        name : e.name, 
        description : e.description, 
        optional : false
      } 
      
      if( e.default )
      param.default = e.default;
      
      paramTypeMake( param, e )
      
      return param;
    })
    
    //
    
    if( tags.returns )
    td.returns = _.arrayAs( tags.returns ).map( ( e ) => 
    { 
      _.assert( _.objectIs( e ), 'Expects signle return tag' );
      
      let returns = 
      { 
        description : e.description 
      }
      
      if( e.type )
      returns.type = e.type.name;
      
      paramTypeMake( returns, e )
      
      return returns;
    })
    
    //
    
    if( tags.example )
    td.examples = _.arrayAs( tags.example ).map( ( e ) => 
    { 
      return { code : e.description } 
    })
    
    //
    
    if( tags.throws )
    td.throws = _.arrayAs( tags.throws ).map( ( e ) => 
    { 
      let returnDescriptor = { description : e.description } 
      paramTypeMake( returnDescriptor, e )
      return returnDescriptor;
    })
    
    //
    
    if( tags.class )
    td.class = unprefix( tags.class.name );
    
    if( tags.namespace )
    td.namespace = unprefix( tags.namespace.name );
    
    if( tags.module )
    td.module = unprefix( tags.module.name );
    
  }
  
  _.assert( _.strDefined( self.templateData.name ), `Entity should have name.\nType:${type}\n Source structure:${_.toJs( self.structure)}\n Source comment:${self.comment}` )
  
  self.templateData.name = unprefix( self.templateData.name );
  
  return self.templateData;
  
  /*  */
  
  function paramTypeMake( param, paramTag )
  { 
    let type = paramTag.type;
    
    if( !_.objectIs( type ) )
    {
      if( self.verbosity )
      _.errLogOnce( `Failed to get type of param tag: ${_.toJs( paramTag )}. \n Comment:${self.comment}`  );
      return;
    }
    
    if( type.type === 'NameExpression' )
    { 
      param.type = type.name;
    }
    else if( type.type === 'OptionalType' )
    {
      param.optional = true;
      return paramTypeMake( param, { type : type.expression } );
    }
    else if( type.type === 'UnionType' )
    { 
      param.type = type.elements.map( ( t ) => t.name ).join( '|' )
    }
    else if( type.type === 'AllLiteral' )
    {
      param.type = '*'
    }
  }
  
  function unprefix( src )
  {
    let firstIsSmall = /[a-z]/.test( src[ 0 ] );
    let secondIsCapital = /[A-Z]/.test( src[ 1 ] );

    if( firstIsSmall && secondIsCapital )
    return src.slice( 1 );
    return src;
  }
}

//

// --
// relations
// --

let Composes =
{
  tags : null
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

  _form,
  
  _typeGet,
  _orphanIs,
  
  _templateDataMake,

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

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

_.docgen[ Self.shortName ] = Self;

})();
