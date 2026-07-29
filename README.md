# Forge Framework v2

 A lightweight dependency injection container inspired by ServiceBag.


TODO (maybe):
- have a checker module that checks for unresolved services after Init and Start lifecycle is completed so we know what Services or Controllers was defined but not called, prevents 67 hours of mindless debugging (didnt happen, yet.)
- Dedicated interface manager/controller to help separate ui-based controlelrs from CRUD-based controllers 
- Load order system with string based priority