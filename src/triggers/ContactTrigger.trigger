trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	TriggerFactory.createHandler(Contact.sObjectType);
}