/**
 * A specific interface for a letter sequence generation. <br>
 * This interface inherits the iterable Java interface so its implementation
 * class can be iterated.
 * 
 * @author n.razafindrabekoto
 * @since R21
 */
public interface LetterSequence extends SequenceIterable<String> {
	
	/**
	 * Retrieves the all possible case number of the sequence.
	 * 
	 * @return the number of case of this sequence.
	 */
	long getCaseNumber();
}
