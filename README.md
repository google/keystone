# Keystone architectural analysis tool

##  Headline features
+ Domain language for describing architectural models
+ generated interactive design structure matrix views
+ generated SysML views
+ integrated simulation environment for latency and stability analysis
+ requirements language with traceability features links requirements to model features

##  Possible approaches
+ server hosted web app
  + stores data in a database
  + easily accessible with zero install
  + user login management required
  + difficult to integrate with source control
  + possibly easier to distribute simulations
+ command line tools
  + independent tools are easier to integrate into existing flows 
  + data stored in text files can be version controlled
  + longer feedback loop
  + less discoverable
  + requires installation
  + more language options
+ standalone desktop app
  + can integrate graphical tools more easily
  + full control over UI presentation
  + more work to get common things working
  + limited language options
+ atom extension
  + already have full text editor
  + can add UI elements via HTML
  + can integrate between text editor and graphical tools
  + difficult to integrate into other tools such as continuous integration systems
