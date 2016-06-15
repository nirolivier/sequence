public class HexTest {

	static char char_a = 0x41;
	static char char_z = 0x5A;
	static char maskz = 0x5A;

	public static void main(String[] args) {
		LetterSequence sequence = LetterSequenceFactory.newFixedSizeBasedString("zzzu");
		System.out.println(sequence.getCaseNumber());
		for (String string : sequence) {
			System.out.println(string);
		}
	}

}
