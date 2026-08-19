#[cfg(test)]
mod test {

    use iced_core::Alignment;
    use iced_core::Degrees;
    use iced_core::Length;
    use iced_core::Pixels;

    #[test]
    fn test_pixels() {
        let pixel = Pixels(5.0);
        let pixel2: Pixels = 30.into();

        assert!(pixel == 5.0.into());
        assert!(pixel2 == 30.into());

        let f: f32 = pixel.into();
        assert!(f == 5.0);

        let p3 = pixel + pixel2;
        assert!(p3 == (5.0 + 30_f32).into());

        let p4 = pixel * pixel2;
        assert!(p4 == (5.0 * 30_f32).into());

        let p5 = pixel / pixel2;
        assert_eq!(p5, Pixels(5.0 / 30.0));
    }

    #[test]
    fn test_angles() {
        let is_in = Degrees::RANGE.contains(&Degrees::from(370.0));
        assert_eq!(is_in, false);

        // match moves if the variable type is not a reference.
        let d1 = Degrees::from(320.0_f32);
        assert_eq!(f32::from(d1), 320.0_f32);
    }

    #[test]
    fn test_alignment() {
        let horizontal = iced_core::alignment::Horizontal::Left;
        let alignment = Alignment::from(horizontal);
        assert_eq!(alignment, Alignment::Start);

        // Alignment keeps positioning locations.
    }

    #[test]
    fn test_length() {
        // Fit, Fill, FillPortion, Shrink, Bounded

        let length = Length::FillPortion(32);
        let l2 = length.min(64);
        println!("{:?}", l2);
    }

    #[test]
    fn test_padding() {
        // Padding is the empty spaces of a box - top, left, right, and bottom.
        //
    }

    #[test]
    fn test_point() {
        // Point<T> is a 2D point, x and y.
        // T can be considered as Num.
        // Point interoperates with Vector.
    }

    #[test]
    fn test_vector() {
        // Vector<T = f32> is a 2D vector.
    }

    #[test]
    fn test_size() {
        // Size<T> is a 2D size.
        // Size::rotate() caclulates the size of the bounding box after the rotation.
        // It supposes the top-left corner of the box is located at the origin.
    }

    #[test]
    fn test_rectangle() {
        // Rectangle represents a boxed region located at top-left corner.
    }

    #[test]
    fn test_rotation() {
        
    }
}
