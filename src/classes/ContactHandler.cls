public with sharing class ContactHandler implements ITrigger{
	private List<Contact> contactList;
	private List<Id> idList;

	public ContactHandler() {
		
	}

	/**
	 * bulkBefore
	 *
	 * This method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	 public void bulkBefore(){}

	/**
	 * bulkAfter
	 *
	 * This method is called prior to execution of an AFTER trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	 public void bulkAfter(){}

	/**
	 * beforeInsert
	 *
	 * This method is called iteratively for each record to be inserted during a BEFORE
	 * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
	 */
	 public void beforeInsert(){

	 }

	/**
	 * beforeUpdate
	 *
	 * This method is called iteratively for each record to be updated during a BEFORE
	 * trigger.
	 */
	 public void beforeUpdate(){}

	/**
	 * beforeDelete
	 *
	 * This method is called iteratively for each record to be deleted during a BEFORE
	 * trigger.
	 */
	 public void beforeDelete(){}

	/**
	 * afterInsert
	 *
	 * This method is called iteratively for each record inserted during an AFTER
	 * trigger. Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The record is 'read only' by this point.
	 */
	 public void afterInsert()
	 {
	 	contactList = trigger.new;
	 	Map<Id, Account> accountMap = new Map<Id, Account>();
	 	for(Contact contactIterator : contactList)
	 	{
	 		accountMap.put(contactIterator.AccountId, new Account(Id = contactIterator.AccountId));
	 	}
	 	updateRecords(accountMap);
	 	contactList = null;
	 }

	/**
	 * afterUpdate
	 *
	 * This method is called iteratively for each record updated during an AFTER
	 * trigger.
	 */
	 public void afterUpdate()
	 {
	 	contactList = trigger.new;
	 	List<Contact> contactListOld = trigger.old;
	 	Map<Id, Account> accountMap = new Map<Id, Account>();
	 	for(Integer i = 0; i<contactList.size(); i++)
	 	{
	 		if(contactList.get(i).AccountId != contactListOld.get(i).AccountId)
	 		{
	 			accountMap.put(contactList.get(i).AccountId, new Account(Id = contactList.get(i).AccountId));
	 			accountMap.put(contactListOld.get(i).AccountId, new Account(Id = contactListOld.get(i).AccountId));
	 		}
	 	}
	 	updateRecords(accountMap);
	 	contactList = null;
	 }

	/**
	 * afterDelete
	 *
	 * This method is called iteratively for each record deleted during an AFTER
	 * trigger.
	 */
	 public void afterDelete()
	 {
	 	contactList = trigger.old;
	 	Map<Id, Account> accountMap = new Map<Id, Account>();
	 	for(Contact contactIterator : contactList)
	 	{
	 		accountMap.put(contactIterator.AccountId, new Account(Id = contactIterator.AccountId));
	 	}
	 	updateRecords(accountMap);
	 }

	public void afterUndelete(){
		contactList = trigger.new;
	 	Map<Id, Account> accountMap = new Map<Id, Account>();
	 	for(Contact contactIterator : contactList)
	 	{
	 		accountMap.put(contactIterator.AccountId, new Account(Id = contactIterator.AccountId));
	 	}
	 	updateRecords(accountMap);
	 	contactList = null;
	}

	/**
	 * andFinally
	 *
	 * This method is called once all records have been processed by the trigger. Use this 
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	 public void andFinally(){}


	 public void updateRecords(Map<Id, Account> accountMap)
	 {
	 	List<Account> accountList = new List<Account>();
	 	AggregateResult[] groupedResults = [select Account.Id, COUNT(Id) from Contact GROUP BY Account.Id];
	 	for(AggregateResult res : groupedResults)
	 	{
	 		Id accountId = (Id)res.get('Id');
	 		Integer countOfContacts = Integer.valueOf(String.valueOf(res.get('expr0')));
	 		if(accountMap.get(accountId) != null)
	 		{
	 			accountMap.get(accountId).Contact_Count__c = (Decimal)countOfContacts;
	 			accountList.add(accountMap.get(accountId));
	 			accountMap.remove(accountId);
	 		}
	 	}
	 	if(trigger.isAfter)
	 	{
	 		if(trigger.isDelete)
	 		{
	 			for(Account accountIterator : accountMap.values())
	 			{
	 				accountIterator.Contact_Count__c = 0;
	 				accountList.add(accountIterator);
	 			}
	 		}
	 	}

	 	update accountList;
	 }
	}