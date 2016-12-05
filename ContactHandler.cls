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
		contactList = trigger.new;
		for(Contact contactIterator : contactList){
			if(contactIterator.Contact_Count__c < 0){
				contactIterator.addError('err');
			}
		}
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
	public void afterInsert(){
		List<Account> accountList = new List<Account>();
		contactList = trigger.new;
		System.debug(contactList);
		idList = new List<Id>();
		/*key - Account's Id
          value - Account's count of contacts
		*/
		Map<Id, Integer> mapId = new Map<Id, Integer>();
		Set<Id> accSet = new Set<Id>();

		for(Contact contactIterator : contactList)
		{
			/*if(mapId.get(contactIterator.AccountId) == null)
			{
				System.debug('test1');
				mapId.put(contactIterator.AccountId, 1);
				System.debug('test2');
			}
			else
			{
				System.debug('test3');
				Integer newValue = mapId.get(contactIterator.AccountId)+1;
				mapId.put(contactIterator.AccountId, newValue);
				System.debug('test4');
			}*/
			accSet.add(contactIterator.AccountId);
		}

		//Set<Id> keysSet = mapId.keySet();
		//System.debug(keysSet);
		accountList = [select Id, Contact_Count__c, (select Id from Contacts) from Account where Account.Id IN:(accSet)];

		for(Account acc : accountList){
			 acc.Contact_Count__c = acc.Contacts.size();
		}

		update accountList;
		System.debug('finish');
		contactList = null;
		idList = null;
	}

	/**
	 * afterUpdate
	 *
	 * This method is called iteratively for each record updated during an AFTER
	 * trigger.
	 */
	public void afterUpdate(){
		contactList = trigger.new;
		List<Contact> contactListOld = trigger.old;
		Set<Id> accountSet = new Set<Id>();
		//System.debug(contactList);
		//System.debug(contactListOld);
		for(Integer i = 0; i<contactList.size(); i++){
			if(contactList.get(i).AccountId != contactListOld.get(i).AccountId){
				accountSet.add(contactList.get(i).AccountId);
				accountSet.add(contactListOld.get(i).AccountId);
			}else{
				
			}
		}
		System.debug(accountSet);
		List<Account> accountList =  [select Id, Contact_Count__c, (select Id from Contacts) from Account where Account.Id IN:(accountSet)];
		System.debug(accountList);
		for(Account accountIterator : accountList){
			 accountIterator.Contact_Count__c = accountIterator.Contacts.size();
		}
		update accountList;
		System.debug('finish');
		contactList = null;
		idList = null;

	}

	/**
	 * afterDelete
	 *
	 * This method is called iteratively for each record deleted during an AFTER
	 * trigger.
	 */
	public void afterDelete(){
		List<Account> accountList = new List<Account>();
		contactList = trigger.old;
		System.debug(contactList);
		idList = new List<Id>();
		/*key - Account's Id
          value - Account's count of contacts
		*/
		Map<Id, Integer> mapId = new Map<Id, Integer>();
		Set<Id> accSet = new Set<Id>();

		for(Contact contactIterator : contactList)
		{
			/*if(mapId.get(contactIterator.AccountId) == null)
			{
				System.debug('test1');
				mapId.put(contactIterator.AccountId, 1);
				System.debug('test2');
			}
			else
			{
				System.debug('test3');
				Integer newValue = mapId.get(contactIterator.AccountId)+1;
				mapId.put(contactIterator.AccountId, newValue);
				System.debug('test4');
			}*/
			accSet.add(contactIterator.AccountId);
		}

		//Set<Id> keysSet = mapId.keySet();
		//System.debug(keysSet);
		accountList = [select Id, Contact_Count__c, (select Id from Contacts) from Account where Account.Id IN:(accSet)];

		for(Account acc : accountList){
			 acc.Contact_Count__c = acc.Contacts.size();
		}

		update accountList;
		System.debug('finish');
		contactList = null;
		idList = null;
	
	}

	/**
	 * andFinally
	 *
	 * This method is called once all records have been processed by the trigger. Use this 
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	public void andFinally(){}
}