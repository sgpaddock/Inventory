AutoTable = AutoTable || {}
AutoTable.counts = new Mongo.Collection('autotable-counts')

SimpleSchema.extendOptions
  autotable: Match.Optional(Object)
