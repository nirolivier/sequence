public abstract class LetterSequenceFactory {
	
	public static LetterSequence newFixedSizeBasedArray(char[] initial){
		return new FixedSizeLetterSequence(initial);
	}
	
	public static LetterSequence newFixedSizeBasedString(String initial){
		return new FixedSizeLetterSequence(initial);
	}
	
	public static LetterSequence newFixedSizeWithUpperCase(int length){
		return new FixedSizeLetterSequence(length, false);
	}
	
	public static LetterSequence newFixedSizeWithLowerCase(int length){
		return new FixedSizeLetterSequence(length, true);
	}
}
