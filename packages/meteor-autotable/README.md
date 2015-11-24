# meteor-autotable
================
A flexible tabular interface for collections backed by simple-schema.

### Table of Contents
- [Quick Start](#quick-start)
- [Customization](#customization)
  - [Settings](#settings)
- [Server-side pagination and filtering](#server-side-pagination-and-filtering)



## Quick Start
Install autotable:

    meteor add hive:autotable

Add an autotable to your project with one line:

    {{> autotable collection=myCollection}}

`myCollection` can be a Meteor collection object (passed through a helper) or a string.

## Customization
The autotable template accepts additional arguments. These can be passed into the template helper directly or via a settings object.

    {{> autotable collection="myCollection" pageLimit=20 actionColumn=true filters=filters}}

    {{> autotable settings=settings}}

    Template.myTable.helpers({
      settings: function() {
        return { 
          collection: Collection,
          pageLimit: 20,
          actionColumn: true,
          filters: function () {
            return { category: Iron.query.get('category') }
          }
        };
      }
    });


### Settings
* `collection`: Mongo.Collection or String. If a string, AutoTable will attempt to find a collection with the correct name.
* `subscription`: String, providing the name of a subscription. This assumes you have used [AutoTable.publish](#server-side-pagination-and-filtering) to publish your collection, and will result in AutoTable attempting to do all collection filtering and paging on the server.
* `pageLimit`: Number. The desired number of table rows per page. 
* `fields`: Array. Each item in the array can either be a string with the name of a field you wish to include, or an object with properties `key`, `label`, `tpl`, and `sortable`, corresponding to a field key (string), field label (string), custom template to render (string or Template), and whether or not the field is sortable (boolean). Strings and objects can be mixed at will. If no `label` is provided, AutoTable will attempt to find a label from SimpleSchema.
* `class`: String. Classes to add to the table element. Default is `autotable table table-condensed`.
* `defaultSort`: String. A default field to sort on. If none is provided, AutoTable will attempt to use the first field given.
* `addButton`: Boolean. True to display a button to add documents (opens an autoform in a modal).
* `actionColumn`: Boolean. True to display a column of actions (clone, edit, delete) - all opening in modals.
* `insertTpl`, `updateTpl`, `cloneTpl, `deleteTpl`: Strings (corresponding to templates) or custom Template objects to be rendered in the above modals instead of the given autoforms.
* `filters`: Function. A function returning a Mongo selector corresponding to a filter set. This is called in an autorun and will be reactive if filters are controlled by reactive data sources (Session vars, ReactiveVars, etc.)

## Server-side Pagination and Filtering
Use `AutoTable.publish` on the server with a `subscription` setting on the client to automatically handle pagination and filtering on the server. 
Input:
* `name`: String. The name of the publication.
* `collectionOrFunction`: Either a Mongo.Collection, or a function returning one.
* `selectorOrFunction`: Either a mongo selector, or a function returning one.
* `noRemoval`: Boolean. With `noRemoval` set to `true`, AutoTable will attempt to keep documents that would otherwise fall out of the record set on the client from doing so. For example, if you and another person are looking at the same row of the table, and are filtering on 'Category', it is possible that the other person could change the Category of the item, and that document would then be removed from the client record set that you are filtering on. `noRemoval` attempts to alleviate this possible pain by keeping all initial documents in the record set until a change in the filter or route.

Inside `collectionOrFunction` or `selectorOrFunction`, `this` will be the publish handler object, so `this.userId` and other properties are available.

Example: 

On the client, chose a publication name:
`{{> autotable collection="Documents" subscription="docs"}}`

On the server:

```js
// Publish the entire collection to all clients
AutoTable.publish('all-docs', Documents);

// Publish a subset of items
AutoTable.publish('some-docs', Documents, { "color": "blue" });

// Publish only to logged in users
AutoTable.publish('docs', function () {
  if (this.userId) {
    return Documents;
  } else {
    return null;
  }
});

// Publish only a users items
AutoTable.publish('docs', Documents, function () {
  return { "owner": this.userId };
});
```
