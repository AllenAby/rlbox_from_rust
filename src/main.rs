use rlbox_from_rust::hello;

fn main() {
    unsafe {
        println!("{}", hello());
    }
}