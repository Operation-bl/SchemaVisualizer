# Hello=)
To create new scratch org for testing - you will need to have your own dev hub and it should be setted as default dev hub for sfdx, you can do it with the command:
* sfdx config:set defaultdevhubusername=<your dev hub user name>
After that run the following commands:
* sfdx force:org:create --definitionfile config/project-scratch-def.json -a SchemaVisualizerDemo --setdefaultusername
* sfdx force:source:push -f -g
* sfdx force:org:open
  That commands will create new scratch org, push there the code, and after that - it will open up in your default browser.
Open "Apps", type "Schema Visualizer" and click the option to open tap with component to test.