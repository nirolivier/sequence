import java.util.Arrays;
import java.util.Iterator;

/**
 * This class provides an iterable sequence of letter with a fixed length. <br>
 * It can give all next sequence of a given character array or of a given text.
 * <br>
 * It provides an ability to chose if the sequence will be in lower case or in
 * upper case. <br>
 * This class can be instantiate by using the factory class.
 * {@link LetterSequenceFactory} <br>
 * <b> NOTE: <br>
 * The remove functionality will generate an exception if a call is attempted
 * because a sequence is never removable.</b>
 * 
 * @author n.razafindrabekoto
 * @since R21
 * @see LetterSequenceFactory
 */
public class FixedSizeLetterSequence implements LetterSequence {
	private static final char A = 0x41;
	private static final char Z = 0x5A;
	private static final char a = 0x61;
	private static final char z = 0x7A;

	private char[] array;
	private long caseNumber = 0;

	/**
	 * Constructs a new instance based on the character array. The next sequence
	 * of this initial array will be generated by this object.
	 * 
	 * @param initial
	 *            the array for initial sequence.
	 */
	public FixedSizeLetterSequence(char[] initial) {
		copyArray(initial);
	}

	/**
	 * Constructs a new instance based on text. The next sequence of this text
	 * will be generated by this object.
	 * 
	 * @param initial
	 *            a text for initial sequence.
	 */
	public FixedSizeLetterSequence(String initial) {
		copyArray(initial.toCharArray());
	}

	/**
	 * Constructs a new instance an initialize the sequence characters 'a' or
	 * 'A' with given length. Set the argument {@code lowerCase} to {@code true}
	 * if the sequence should be generated in lower case. Otherwise, it will be
	 * generated in upper case.
	 * 
	 * @param length
	 *            the length of the sequence
	 * @param lowerCase
	 *            true if sequence need to be in lower case
	 */
	public FixedSizeLetterSequence(int length, boolean lowerCase) {
		this.array = new char[length];
		for (int i = 0; i < length - 1; i++) {
			if (lowerCase) {
				array[i] = a;
			} else {
				array[i] = A;
			}
		}
	}

	/**
	 * {@inheritDoc}
	 */
	public long getCaseNumber() {
		return caseNumber;
	}

	/**
	 * Makes a defensive copy so that the array in parameter is not impacted
	 * with a change.
	 * 
	 * @param array
	 *            an array of characters.
	 */
	private void copyArray(char[] array) {
		assertLetters(array);
		this.array = Arrays.copyOf(array, array.length);
		caseNumber = caseNumberOf(array);
	}

	/**
	 * Asserts if each character is letter in the array.
	 * 
	 * @param array
	 *            an array of characters.
	 */
	private void assertLetters(char[] array) {
		for (char ch : array) {
			if (!Character.isLetter(ch)) {
				throw new IllegalArgumentException("The array list contains a character which is not a letter.");
			}
		}
	}

	/**
	 * Calculates the sequence case number of the character array.
	 * 
	 * @param array
	 *            an array of characters.
	 * @return the sequence case number
	 */
	private long caseNumberOf(char[] array) {
		long num = 1;
		for (int i = 0; i < array.length; i++) {
			if (i == 0 && Character.isLowerCase(array[i]) && array[i] == z) {
				num *= (z - array[i] + 0x01);
			} else if (i == 0 && Character.isUpperCase(array[i]) && array[i] == Z) {
				num *= (Z - array[i] + 0x01);
			} else {
				num *= 26;
			}
		}
		return array.length <= 0 ? 0 : num;
	}

	/**
	 * Check if the character is belong to the range of upper case letter. The
	 * letter 'Z' is excluded.
	 * 
	 * @param c
	 *            the character
	 * @return True if the condition is met.
	 */
	private boolean isInUpperCaseRange(char c) {
		return (A <= c && c < Z);
	}

	/**
	 * Check if the character is belong to the range of lower case letter. The
	 * letter 'Z' is excluded.
	 * 
	 * @param c
	 *            the character
	 * @return True if the condition is met.
	 */
	private boolean isInLowerCaseRange(char c) {
		return a <= c && c < z;
	}

	/**
	 * Provides the iterator of this sequence
	 */
	@Override
	public Iterator<String> iterator() {
		return new LetterSequenceIterator();
	}

	/**
	 * An iterator class for the letter sequence. It provides the next
	 * generation of the sequence. <br>
	 * <b> NOTE: The remove functionality will generate an exception if a call
	 * is attempted because a sequence is never removable.</b>
	 * 
	 * @author n.razafindrabekoto
	 * @since R21
	 */
	private class LetterSequenceIterator implements Iterator<String> {

		private long itCount;

		/**
		 * Constructs a new instance of this class
		 */
		public LetterSequenceIterator() {
			itCount = caseNumber - 1;
		}

		/**
		 * Check if there is a next sequence. True if it exists.
		 */
		@Override
		public boolean hasNext() {
			return itCount > 0;
		}

		/**
		 * Provides the next sequence.
		 */
		@Override
		public String next() {
			String res = generate(array);
			itCount--;
			return res;
		}

		/**
		 * Generates the sequence based on the given character array.
		 * 
		 * @param array
		 *            the character array.
		 * @return a new sequence.
		 */
		private String generate(char[] array) {
			int lastIdx = array.length - 1;
			String result = "";
			for (int i = lastIdx; i >= 0; i--) {
				if (isInLowerCaseRange(array[i]) || isInUpperCaseRange(array[i])) {
					array[i] = (char) (array[i] + 0x01);
					break;
				} else if (array[i] == Z) {
					array[i] = A;
				} else if (array[i] == z) {
					array[i] = a;
				}
			}
			for (int i = 0; i < array.length; i++) {
				result += array[i];
			}
			return result;
		}

		@Override
		public void remove() {
			throw new RuntimeException("Remove method should not be used for this iterator.");
		}

	}

}